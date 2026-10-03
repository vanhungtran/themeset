/* ==========================================================================
   themeset website extras: reading progress bar, back-to-top button and
   click-to-zoom figures. Mirrors the script in vignettes/lightbox.html.
   No external scripts or fonts are loaded.
   ========================================================================== */
(function () {
  function ready(fn) {
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', fn);
    } else {
      fn();
    }
  }

  ready(function () {
    var body = document.body;

    /* Reading progress bar and back-to-top button */
    var bar = document.createElement('div');
    bar.id = 'rpb';
    body.appendChild(bar);

    var top = document.createElement('button');
    top.id = 'btt';
    top.type = 'button';
    top.title = 'Back to top';
    top.setAttribute('aria-label', 'Back to top');
    top.textContent = String.fromCharCode(8593);  /* up arrow */
    body.appendChild(top);

    function onScroll() {
      var s = document.documentElement;
      var max = s.scrollHeight - s.clientHeight;
      bar.style.width = (max > 0 ? Math.min(s.scrollTop / max * 100, 100) : 0) + '%';
      top.classList.toggle('show', window.scrollY > 480);
    }
    window.addEventListener('scroll', onScroll, { passive: true });
    top.addEventListener('click', function () {
      window.scrollTo({ top: 0, behavior: 'smooth' });
    });
    onScroll();

    /* Click-to-zoom figures, with the arrow keys to move between them */
    var viewer = document.createElement('div');
    viewer.id = 'ts-viewer';
    viewer.setAttribute('role', 'dialog');
    viewer.setAttribute('aria-label', 'Figure viewer');
    var big = document.createElement('img');
    viewer.appendChild(big);
    body.appendChild(viewer);

    var figures = [];
    var current = 0;

    function candidates() {
      return Array.prototype.filter.call(document.querySelectorAll('img'), function (img) {
        if (img.closest('nav, header, footer, a, #ts-viewer')) return false;
        return img.naturalWidth === 0 || img.naturalWidth >= 120;
      });
    }
    function mark() {
      candidates().forEach(function (img) { img.classList.add('ts-zoom'); });
    }
    function show(i) {
      figures = candidates();
      if (!figures.length) return;
      current = (i + figures.length) % figures.length;
      big.src = figures[current].currentSrc || figures[current].src;
      big.alt = figures[current].alt || '';
      viewer.classList.add('open');
    }
    function hide() {
      viewer.classList.remove('open');
    }

    mark();
    window.addEventListener('load', mark);
    document.addEventListener('click', function (e) {
      var img = e.target;
      if (!img || img.tagName !== 'IMG' || !img.classList.contains('ts-zoom')) return;
      var i = candidates().indexOf(img);
      if (i < 0) return;
      e.preventDefault();
      show(i);
    });
    viewer.addEventListener('click', hide);
    document.addEventListener('keydown', function (e) {
      if (!viewer.classList.contains('open')) return;
      if (e.key === 'Escape') hide();
      else if (e.key === 'ArrowRight') show(current + 1);
      else if (e.key === 'ArrowLeft') show(current - 1);
    });
  });
})();
