// ==UserScript==
// @name        Blinders
// @namespace   nilock.github.io
// @description Removes distracting content from webpages
// @include     *
// @version     1
// @grant       none
// ==/UserScript==

// for stackexchange sites
var hnq = document.getElementById('hot-network-questions');
hnq.parentNode.removeChild(hnq);