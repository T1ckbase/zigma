import { expect, test } from 'bun:test';
import { ZigMarkdown } from '.';

const zigma = await ZigMarkdown.init();

test('unordered lists', () => {
  expect(
    zigma.render(`- Spam
- Spam
- Spam
- Eggs
- Bacon
- Spam

* Spam
* Spam
* Spam
* Eggs
* Bacon
* Spam

+ Spam
+ Spam
+ Spam
+ Eggs
+ Bacon
+ Spam
`),
  ).toBe(`<ul>
<li>Spam</li>
<li>Spam</li>
<li>Spam</li>
<li>Eggs</li>
<li>Bacon</li>
<li>Spam</li>
</ul>
<ul>
<li>Spam</li>
<li>Spam</li>
<li>Spam</li>
<li>Eggs</li>
<li>Bacon</li>
<li>Spam</li>
</ul>
<ul>
<li>Spam</li>
<li>Spam</li>
<li>Spam</li>
<li>Eggs</li>
<li>Bacon</li>
<li>Spam</li>
</ul>
`);
});
