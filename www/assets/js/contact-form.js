// ============================================
// AIDXON 문의 폼 — Supabase 저장 로직
// ============================================

(function () {
  const overlay = document.getElementById('modal-overlay');
  const form = document.getElementById('contact-form');
  const success = document.getElementById('form-success');
  const submitBtn = form ? form.querySelector('.form-submit') : null;
  const tabs = document.querySelector('.modal-tabs');

  if (!form || !overlay) return;

  // Supabase 클라이언트 초기화
  let supabase = null;
  const cfg = window.SUPABASE_CONFIG || {};
  if (cfg.url && cfg.anonKey && window.supabase && window.supabase.createClient) {
    supabase = window.supabase.createClient(cfg.url, cfg.anonKey);
  }

  // ===== 모달 열기/닫기 =====
  window.openModal = function (category) {
    form.style.display = '';
    form.reset();
    success.style.display = 'none';
    if (tabs) tabs.style.display = '';
    document.getElementById('category').value = category;
    document.querySelector('.modal-title').textContent = titleOf(category);
    document.querySelectorAll('.modal-tab').forEach(function (tab) {
      tab.classList.toggle('active', tab.dataset.category === category);
    });
    overlay.classList.add('open');
    document.body.style.overflow = 'hidden';
  };

  window.closeModal = function () {
    overlay.classList.remove('open');
    document.body.style.overflow = '';
  };

  window.selectTab = function (tab) {
    document.querySelectorAll('.modal-tab').forEach(function (t) { t.classList.remove('active'); });
    tab.classList.add('active');
    document.getElementById('category').value = tab.dataset.category;
    document.querySelector('.modal-title').textContent = titleOf(tab.dataset.category);
  };

  function titleOf(cat) {
    return cat === '도입상담' ? '도입 상담 신청'
      : cat === '프로젝트제안' ? '프로젝트 제안 요청'
      : '문의하기';
  }

  overlay.addEventListener('click', function (e) {
    if (e.target === overlay) window.closeModal();
  });
  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape') window.closeModal();
  });

  // ===== 폼 제출 =====
  window.handleSubmit = async function (e) {
    e.preventDefault();

    const payload = {
      category: form.querySelector('#category').value,
      company: form.querySelector('#company').value.trim() || null,
      name: form.querySelector('#name').value.trim(),
      phone: form.querySelector('#phone').value.trim(),
      email: form.querySelector('#email').value.trim() || null,
      message: form.querySelector('#message').value.trim() || null,
      user_agent: navigator.userAgent,
      referrer: document.referrer || null
    };

    if (submitBtn) {
      submitBtn.disabled = true;
      submitBtn.textContent = '전송 중...';
    }

    try {
      if (!supabase) {
        throw new Error('Supabase 설정이 필요합니다. www/assets/js/supabase-config.js 를 확인해주세요.');
      }

      const { error } = await supabase.from('contacts').insert(payload);
      if (error) throw error;

      form.style.display = 'none';
      if (tabs) tabs.style.display = 'none';
      success.style.display = 'block';
    } catch (err) {
      console.error('[contact-form]', err);
      alert('문의 접수 중 오류가 발생했습니다.\n잠시 후 다시 시도해주시거나 ad@aidxon.com 으로 연락 부탁드립니다.');
    } finally {
      if (submitBtn) {
        submitBtn.disabled = false;
        submitBtn.textContent = '문의 보내기';
      }
    }

    return false;
  };
})();
