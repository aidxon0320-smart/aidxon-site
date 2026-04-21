// ===== Navigation =====
(function () {
  const header = document.getElementById('gnb');
  const toggle = document.querySelector('.menu-toggle');
  const mobileNav = document.getElementById('mobile-nav');
  const navLinks = document.querySelectorAll('.nav-links a');
  const mobileLinks = mobileNav.querySelectorAll('a');
  const sections = document.querySelectorAll('main .section');

  // Remove no-js class
  document.documentElement.classList.remove('no-js');
  document.documentElement.classList.add('js');

  // Scroll -> header background
  function onScroll() {
    if (window.scrollY > 60) {
      header.classList.add('scrolled');
    } else {
      header.classList.remove('scrolled');
    }
  }
  window.addEventListener('scroll', onScroll, { passive: true });
  onScroll();

  // Mobile menu toggle
  toggle.addEventListener('click', function () {
    toggle.classList.toggle('active');
    mobileNav.classList.toggle('open');
    document.body.style.overflow = mobileNav.classList.contains('open') ? 'hidden' : '';
  });

  function closeMobile() {
    toggle.classList.remove('active');
    mobileNav.classList.remove('open');
    document.body.style.overflow = '';
  }

  mobileLinks.forEach(function (link) {
    link.addEventListener('click', closeMobile);
  });

  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape') closeMobile();
  });

  // Active nav link on scroll
  var observer = new IntersectionObserver(
    function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          var id = entry.target.id;
          navLinks.forEach(function (link) {
            link.classList.toggle('active', link.getAttribute('href') === '#' + id);
          });
        }
      });
    },
    { rootMargin: '-20% 0px -60% 0px' }
  );

  sections.forEach(function (section) {
    if (section.id) observer.observe(section);
  });
})();
