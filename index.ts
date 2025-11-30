import fs from 'node:fs/promises';

export interface Exports {
  alloc: (arg0: number) => number;
  free: (arg0: number, arg1: number) => void;
  get_output_len: () => number;
  get_output_ptr: () => number;
  render: (arg0: number, arg1: number) => number;
  free_output_buffer: () => void;
  readonly memory: WebAssembly.Memory;
}

export class ZigMarkdown {
  private encoder = new TextEncoder();
  private decoder = new TextDecoder();
  wasm: Exports;

  private constructor(wasm: Exports) {
    this.wasm = wasm;
  }

  static async init() {
    const source = await fs.readFile('./zig-out/bin/zigma.wasm');
    const { instance } = await WebAssembly.instantiate(source, {
      env: {},
    });

    const wasm = instance.exports;

    return new ZigMarkdown(wasm as unknown as Exports);
  }

  render(content: string) {
    if (!this.wasm) {
      throw new Error('WASM not initialized. Call init() first.');
    }

    const bytes = this.encoder.encode(content);
    const len = bytes.length;

    const ptr = this.wasm.alloc(len);

    const memBuffer = new Uint8Array(this.wasm.memory.buffer);
    memBuffer.set(bytes, ptr);

    const status = this.wasm.render(ptr, len);

    const outLen = this.wasm.get_output_len();
    const outPtr = this.wasm.get_output_ptr();

    const resultBuffer = new Uint8Array(this.wasm.memory.buffer, outPtr, outLen);
    const resultString = this.decoder.decode(resultBuffer);

    if (status !== 0) {
      throw new Error(`Zig Markdown Error: ${resultString}`);
    }

    return resultString;
  }
}
