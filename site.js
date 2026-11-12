(function () {
  // Mobile drawer: real buttons, Escape to close, focus handled.
  var body = document.body;
  var openBtn = document.querySelector('.nav-hamburger');
  var closeBtn = document.querySelector('.nav-drawer-close');
  var drawer = document.getElementById('nav-drawer');
  function setOpen(open) {
    body.classList.toggle('nav-open', open);
    openBtn.setAttribute('aria-expanded', String(open));
    if (open) setTimeout(function () { drawer.querySelector('a').focus(); }, 60);
    else openBtn.focus();
  }
  openBtn.addEventListener('click', function () { setOpen(true); });
  closeBtn.addEventListener('click', function () { setOpen(false); });
  document.querySelector('.nav-overlay').addEventListener('click', function () { setOpen(false); });
  drawer.querySelectorAll('a').forEach(function (a) {
    a.addEventListener('click', function () {
      body.classList.remove('nav-open');
      openBtn.setAttribute('aria-expanded', 'false');
    });
  });
  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape' && body.classList.contains('nav-open')) setOpen(false);
  });

  // Highlight the section in view in the desktop nav.
  if (!('IntersectionObserver' in window)) return;
  var links = document.querySelectorAll('.site-nav a');
  var observer = new IntersectionObserver(function (entries) {
    entries.forEach(function (entry) {
      if (!entry.isIntersecting) return;
      links.forEach(function (link) {
        if (link.getAttribute('href') === '#' + entry.target.id) link.setAttribute('aria-current', 'true');
        else link.removeAttribute('aria-current');
      });
    });
  }, { rootMargin: '-45% 0px -50% 0px' });
  document.querySelectorAll('main section[id]').forEach(function (sec) { observer.observe(sec); });
})();
