/* ==========================================================================
   Yield Router -- Application Logic
   No frameworks. No build tools. Just JavaScript.
   ========================================================================== */

(function () {
  'use strict';

  /* -----------------------------------------------------------------------
     State
     ----------------------------------------------------------------------- */
  const state = {
    walletConnected: false,
    walletAddress: null,
    currentView: 'landing', // 'landing' | 'deposit' | 'portfolio' | 'withdraw' | 'vault'
    mockData: {
      tvl: 2100000,
      netApy: 8.4,
      users: 312,
      yieldPaid: 180000,
      sharePrice: 1.0136,
      walletBalance: 12450.0,
      depositCap: 1000000,
      depositCapUsed: 200000,
      minDeposit: 10,
      userShares: 12283.47,
      userValue: 12614.20,
      userEarned: 164.20,
      userEarnedPct: 1.32,
      firstDeposit: 'Jan 12, 2026',
      allocations: [
        { name: 'Aave V3', pct: 32, color: '#B6509E', balance: 1340000, apy: 6.8, address: '0xaaaa...bbbb' },
        { name: 'Morpho Blue', pct: 45, color: '#2470FF', balance: 1890000, apy: 8.2, address: '0xcccc...dddd' },
        { name: 'Aerodrome', pct: 18, color: '#0098EA', balance: 630000, apy: 7.5, address: '0xeeee...ffff' },
        { name: 'Idle Buffer', pct: 5, color: 'rgba(255,255,255,0.15)', balance: 340000, apy: 0, address: null }
      ],
      vaultAddress: '0x1234...5678'
    }
  };

  /* -----------------------------------------------------------------------
     DOM Helpers
     ----------------------------------------------------------------------- */
  const $ = (sel, ctx) => (ctx || document).querySelector(sel);
  const $$ = (sel, ctx) => Array.from((ctx || document).querySelectorAll(sel));

  /* -----------------------------------------------------------------------
     Formatting
     ----------------------------------------------------------------------- */
  function formatUSD(n) {
    if (n >= 1000000) return '$' + (n / 1000000).toFixed(1) + 'M';
    if (n >= 1000) return '$' + (n / 1000).toFixed(0) + 'K';
    return '$' + n.toFixed(2);
  }

  function formatNumber(n, decimals) {
    return n.toLocaleString('en-US', { minimumFractionDigits: decimals, maximumFractionDigits: decimals });
  }

  function truncateAddress(addr) {
    if (!addr) return '';
    return addr.slice(0, 6) + '...' + addr.slice(-4);
  }

  /* -----------------------------------------------------------------------
     Count-Up Animation (landing page stats only)
     ----------------------------------------------------------------------- */
  function animateCountUp(el, target, duration, formatter) {
    const start = performance.now();
    const ease = (t) => {
      // cubic-bezier(0.23, 1, 0.32, 1) approximation
      return 1 - Math.pow(1 - t, 3);
    };

    function tick(now) {
      const elapsed = now - start;
      const progress = Math.min(elapsed / duration, 1);
      const eased = ease(progress);
      const current = eased * target;
      el.textContent = formatter(current);
      if (progress < 1) requestAnimationFrame(tick);
    }

    requestAnimationFrame(tick);
  }

  /* -----------------------------------------------------------------------
     Intersection Observer for landing sections
     ----------------------------------------------------------------------- */
  function setupScrollAnimations() {
    const sections = $$('.landing-section');
    if (!sections.length) return;

    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.classList.add('landing-section--visible');
            observer.unobserve(entry.target);
          }
        });
      },
      { threshold: 0.15 }
    );

    sections.forEach((s) => observer.observe(s));
  }

  function setupStatCountUp() {
    const statSection = $('#stats-section');
    if (!statSection) return;

    let animated = false;
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting && !animated) {
            animated = true;
            animateCountUp($('#stat-tvl'), state.mockData.tvl, 1200, (v) => formatUSD(v));
            animateCountUp($('#stat-apy'), state.mockData.netApy, 1200, (v) => v.toFixed(1) + '%');
            animateCountUp($('#stat-users'), state.mockData.users, 1200, (v) => Math.round(v).toLocaleString());
            animateCountUp($('#stat-yield'), state.mockData.yieldPaid, 1200, (v) => formatUSD(v));
            observer.unobserve(statSection);
          }
        });
      },
      { threshold: 0.3 }
    );

    observer.observe(statSection);
  }

  /* -----------------------------------------------------------------------
     Navigation / View Switching
     ----------------------------------------------------------------------- */
  function showView(viewName) {
    state.currentView = viewName;

    // Hide all views
    $$('.view').forEach((v) => v.classList.remove('view--active'));

    // Show target view
    const target = $('#view-' + viewName);
    if (target) {
      target.classList.remove('view--active');
      // Force reflow for re-animation
      void target.offsetWidth;
      target.classList.add('view--active');
    }

    // Update tab states (visual + ARIA)
    $$('.topbar-tab').forEach((tab) => {
      tab.classList.remove('topbar-tab--active');
      tab.setAttribute('aria-selected', 'false');
      if (tab.dataset.view === viewName) {
        tab.classList.add('topbar-tab--active');
        tab.setAttribute('aria-selected', 'true');
      }
    });

    $$('.bottom-tab').forEach((tab) => {
      tab.classList.remove('bottom-tab--active');
      tab.setAttribute('aria-selected', 'false');
      if (tab.dataset.view === viewName) {
        tab.classList.add('bottom-tab--active');
        tab.setAttribute('aria-selected', 'true');
      }
    });

    // Scroll to top when switching dApp views
    if (viewName !== 'landing') {
      window.scrollTo({ top: 0, behavior: 'instant' });
    }
  }

  function setupNavigation() {
    // Top bar tabs
    $$('.topbar-tab').forEach((tab) => {
      tab.addEventListener('click', (e) => {
        e.preventDefault();
        const view = tab.dataset.view;
        if (!view) return;

        if (!state.walletConnected && view !== 'landing') {
          openWalletModal();
          return;
        }
        showView(view);
      });
    });

    // Bottom tabs (mobile)
    $$('.bottom-tab').forEach((tab) => {
      tab.addEventListener('click', (e) => {
        e.preventDefault();
        const view = tab.dataset.view;
        if (!view) return;

        if (!state.walletConnected) {
          openWalletModal();
          return;
        }
        showView(view);
      });
    });

    // Logo goes to landing
    const logo = $('.topbar-logo');
    if (logo) {
      logo.addEventListener('click', (e) => {
        e.preventDefault();
        showView('landing');
      });
    }
  }

  /* -----------------------------------------------------------------------
     Wallet Connection
     ----------------------------------------------------------------------- */
  function openWalletModal() {
    const backdrop = $('#wallet-modal');
    if (backdrop) {
      backdrop.classList.add('modal-backdrop--open');
      // Hide any previous error
      const err = $('.modal-error', backdrop);
      if (err) err.classList.remove('visible');
      // Focus the first wallet option for keyboard accessibility
      const firstOption = $('.wallet-option', backdrop);
      if (firstOption) setTimeout(() => firstOption.focus(), 100);
      // Trap focus inside modal
      backdrop._focusTrap = function (e) {
        if (e.key !== 'Tab') return;
        const focusable = $$('button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])', backdrop.querySelector('.modal'));
        if (!focusable.length) return;
        const first = focusable[0];
        const last = focusable[focusable.length - 1];
        if (e.shiftKey && document.activeElement === first) {
          e.preventDefault();
          last.focus();
        } else if (!e.shiftKey && document.activeElement === last) {
          e.preventDefault();
          first.focus();
        }
      };
      document.addEventListener('keydown', backdrop._focusTrap);
    }
  }

  function closeWalletModal() {
    const backdrop = $('#wallet-modal');
    if (backdrop) {
      backdrop.classList.remove('modal-backdrop--open');
      if (backdrop._focusTrap) {
        document.removeEventListener('keydown', backdrop._focusTrap);
        backdrop._focusTrap = null;
      }
      // Return focus to wallet button
      const walletBtn = $('#wallet-btn');
      if (walletBtn) walletBtn.focus();
    }
  }

  async function connectWallet(providerName) {
    const err = $('.modal-error', $('#wallet-modal'));

    // Check for window.ethereum
    if (!window.ethereum) {
      if (err) {
        err.textContent = 'No wallet detected. Please install ' + providerName + ' and try again.';
        err.classList.add('visible');
      }
      return;
    }

    try {
      const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
      if (accounts && accounts.length > 0) {
        state.walletAddress = accounts[0];
        state.walletConnected = true;

        // Check chain (Base = 0x2105 = 8453)
        const chainId = await window.ethereum.request({ method: 'eth_chainId' });
        if (chainId !== '0x2105') {
          try {
            await window.ethereum.request({
              method: 'wallet_switchEthereumChain',
              params: [{ chainId: '0x2105' }]
            });
          } catch (switchErr) {
            // If chain not added, try adding it
            if (switchErr.code === 4902) {
              await window.ethereum.request({
                method: 'wallet_addEthereumChain',
                params: [{
                  chainId: '0x2105',
                  chainName: 'Base',
                  rpcUrls: ['https://mainnet.base.org'],
                  nativeCurrency: { name: 'ETH', symbol: 'ETH', decimals: 18 },
                  blockExplorerUrls: ['https://basescan.org']
                }]
              });
            }
          }
        }

        onWalletConnected();
        closeWalletModal();
        showView('deposit');
      }
    } catch (e) {
      if (err) {
        if (e.code === 4001) {
          err.textContent = 'Connection was cancelled. Try again?';
        } else {
          err.textContent = 'Could not connect. Please try again.';
        }
        err.classList.add('visible');
      }
    }
  }

  function simulateConnect() {
    // For demo: simulate wallet connection without actual provider
    state.walletAddress = '0x742d35Cc6634C0532925a3b844Bc9e7595f2bD18';
    state.walletConnected = true;
    onWalletConnected();
    closeWalletModal();
    showView('deposit');
  }

  function onWalletConnected() {
    // Update wallet button
    const walletBtn = $('#wallet-btn');
    if (walletBtn) {
      walletBtn.className = 'btn-wallet--connected';
      walletBtn.innerHTML =
        '<span class="wallet-identicon"></span>' +
        '<span>' + truncateAddress(state.walletAddress) + '</span>';
    }

    // Enable tabs
    $$('.topbar-tab--disabled').forEach((tab) => {
      tab.classList.remove('topbar-tab--disabled');
    });

    // Populate dApp data
    populateDepositView();
    populatePortfolioView();
    populateWithdrawView();
    populateVaultInfoView();
  }

  function disconnectWallet() {
    state.walletConnected = false;
    state.walletAddress = null;

    const walletBtn = $('#wallet-btn');
    if (walletBtn) {
      walletBtn.className = 'btn-wallet';
      walletBtn.textContent = 'Connect Wallet';
    }

    // Disable tabs
    $$('.topbar-tab[data-view]').forEach((tab) => {
      if (tab.dataset.view !== 'landing') {
        tab.classList.add('topbar-tab--disabled');
      }
    });

    showView('landing');
  }

  function setupWalletModal() {
    // Open modal
    const walletBtn = $('#wallet-btn');
    if (walletBtn) {
      walletBtn.addEventListener('click', () => {
        if (state.walletConnected) {
          // Simple disconnect on click when connected
          disconnectWallet();
        } else {
          openWalletModal();
        }
      });
    }

    // CTA buttons that trigger wallet connect
    $$('[data-action="connect"]').forEach((btn) => {
      btn.addEventListener('click', (e) => {
        e.preventDefault();
        if (state.walletConnected) {
          showView('deposit');
        } else {
          openWalletModal();
        }
      });
    });

    // Close modal on backdrop click
    const backdrop = $('#wallet-modal');
    if (backdrop) {
      backdrop.addEventListener('click', (e) => {
        if (e.target === backdrop) closeWalletModal();
      });
    }

    // Close button
    const closeBtn = $('.modal-close', backdrop);
    if (closeBtn) closeBtn.addEventListener('click', closeWalletModal);

    // Escape key
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape') closeWalletModal();
    });

    // Wallet options -- use simulate for demo since we cannot guarantee window.ethereum
    $$('.wallet-option').forEach((opt) => {
      opt.addEventListener('click', () => {
        const provider = opt.dataset.wallet;
        if (window.ethereum) {
          connectWallet(provider);
        } else {
          simulateConnect();
        }
      });
    });
  }

  /* -----------------------------------------------------------------------
     Deposit View
     ----------------------------------------------------------------------- */
  function populateDepositView() {
    const d = state.mockData;
    const balEl = $('#deposit-balance');
    if (balEl) balEl.textContent = 'Wallet balance: ' + formatNumber(d.walletBalance, 2) + ' USDC';

    const previewShares = $('#deposit-preview-shares');
    const previewPrice = $('#deposit-preview-price');
    const previewApy = $('#deposit-preview-apy');
    if (previewPrice) previewPrice.textContent = formatNumber(d.sharePrice, 4) + ' USDC per yrUSDC';
    if (previewApy) previewApy.textContent = d.netApy.toFixed(1) + '%';

    const capEl = $('#deposit-cap-info');
    if (capEl) {
      const remaining = d.depositCap - d.depositCapUsed;
      capEl.textContent = 'Vault deposit cap: ' + formatUSD(remaining) + ' remaining. Minimum deposit: ' + d.minDeposit + ' USDC.';
    }
  }

  function setupDepositForm() {
    const input = $('#deposit-amount');
    const btn = $('#deposit-btn');
    const previewShares = $('#deposit-preview-shares');
    const validation = $('#deposit-validation');
    const inputContainer = input ? input.closest('.input-amount-container') : null;

    if (!input || !btn) return;

    input.addEventListener('input', () => {
      const raw = input.value.replace(/[^0-9.]/g, '');
      const val = parseFloat(raw) || 0;
      const d = state.mockData;
      let hasError = false;

      // Clear validation
      if (validation) {
        validation.textContent = '';
        validation.className = 'input-validation-msg';
      }

      // Preview
      if (previewShares && val > 0) {
        const shares = val / d.sharePrice;
        previewShares.textContent = '~' + formatNumber(shares, 2) + ' yrUSDC';
      } else if (previewShares) {
        previewShares.textContent = '--';
      }

      // Validation
      if (val > 0 && val < d.minDeposit) {
        if (validation) {
          validation.textContent = 'Minimum deposit is ' + d.minDeposit + ' USDC.';
          validation.className = 'input-validation-msg input-validation-msg--error';
        }
        btn.disabled = true;
        hasError = true;
      } else if (val > d.walletBalance) {
        if (validation) {
          validation.textContent = 'You only have ' + formatNumber(d.walletBalance, 2) + ' USDC in your wallet.';
          validation.className = 'input-validation-msg input-validation-msg--error';
        }
        btn.disabled = true;
        hasError = true;
      } else if (val > (d.depositCap - d.depositCapUsed)) {
        if (validation) {
          validation.textContent = 'This deposit would exceed the vault cap. Maximum additional deposit: ' + formatUSD(d.depositCap - d.depositCapUsed) + '.';
          validation.className = 'input-validation-msg input-validation-msg--warning';
        }
        btn.disabled = true;
      } else if (val > 0) {
        btn.disabled = false;
      } else {
        btn.disabled = true;
      }

      // Toggle error border on input container per visual spec
      if (inputContainer) {
        inputContainer.classList.toggle('input-amount-container--error', hasError);
      }
    });

    // MAX button
    const maxBtn = $('#deposit-max');
    if (maxBtn) {
      maxBtn.addEventListener('click', () => {
        input.value = state.mockData.walletBalance;
        input.dispatchEvent(new Event('input'));
      });
    }

    // Deposit button
    btn.addEventListener('click', async () => {
      if (btn.disabled) return;
      const val = parseFloat(input.value) || 0;
      if (val <= 0) return;

      // Simulate transaction flow
      const originalText = btn.textContent;

      // Step 1: Confirm in wallet
      btn.disabled = true;
      btn.innerHTML = '<span class="spinner"></span> Confirm in wallet...';
      await delay(1500);

      // Step 2: Pending
      btn.innerHTML = '<span class="spinner"></span> Depositing...';
      await delay(2000);

      // Step 3: Success
      btn.innerHTML = originalText;
      btn.disabled = true;

      const shares = val / state.mockData.sharePrice;
      showTxResult('deposit', 'success',
        'Deposited ' + formatNumber(val, 2) + ' USDC successfully',
        'You received ' + formatNumber(shares, 2) + ' yrUSDC',
        '0xabc123...def456'
      );

      // Reset
      input.value = '';
      input.dispatchEvent(new Event('input'));
    });
  }

  function showTxResult(formId, type, title, detail, txHash) {
    const container = $('#' + formId + '-tx-result');
    if (!container) return;

    container.className = 'tx-result tx-' + type + ' visible';
    const titleEl = $('.tx-result-title', container);
    const detailEl = $('.tx-result-detail', container);
    const linkEl = $('.tx-result-link', container);

    if (titleEl) titleEl.textContent = title;
    if (detailEl) detailEl.textContent = detail;
    if (linkEl) linkEl.href = 'https://basescan.org/tx/' + txHash;

    // Icon
    const iconEl = $('.tx-result-icon', container);
    if (iconEl) iconEl.innerHTML = type === 'success' ? '&#10003;' : '&#10005;';
  }

  /* -----------------------------------------------------------------------
     Portfolio View
     ----------------------------------------------------------------------- */
  function populatePortfolioView() {
    const d = state.mockData;
    const valEl = $('#portfolio-value');
    const earnedEl = $('#portfolio-earned');
    const sinceEl = $('#portfolio-since');

    if (valEl) valEl.textContent = '$' + formatNumber(d.userValue, 2);
    if (earnedEl) earnedEl.textContent = '+$' + formatNumber(d.userEarned, 2) + ' earned (+' + d.userEarnedPct.toFixed(2) + '%)';
    if (sinceEl) sinceEl.textContent = 'since your first deposit on ' + d.firstDeposit;

    // Data rows
    const sharesEl = $('#portfolio-shares');
    const priceEl = $('#portfolio-price');
    const apyEl = $('#portfolio-apy');
    const shareOfTvl = $('#portfolio-share-tvl');

    if (sharesEl) sharesEl.textContent = formatNumber(d.userShares, 2) + ' yrUSDC';
    if (priceEl) priceEl.textContent = formatNumber(d.sharePrice, 4) + ' USDC';
    if (apyEl) apyEl.textContent = d.netApy.toFixed(1) + '%';
    if (shareOfTvl) shareOfTvl.textContent = ((d.userValue / d.tvl) * 100).toFixed(1) + '%';

    // Allocation bar
    populateAllocationBar('#portfolio-allocation-bar', '#portfolio-allocation-legend');
  }

  function populateAllocationBar(barSel, legendSel) {
    const bar = $(barSel);
    const legend = $(legendSel);
    if (!bar || !legend) return;

    bar.innerHTML = '';
    legend.innerHTML = '';

    state.mockData.allocations.forEach((a) => {
      const seg = document.createElement('div');
      seg.className = 'allocation-segment';
      seg.style.width = a.pct + '%';
      seg.style.background = a.color;
      bar.appendChild(seg);

      const item = document.createElement('div');
      item.className = 'allocation-legend-item';
      item.innerHTML =
        '<span class="allocation-legend-dot" style="background:' + a.color + '"></span>' +
        '<span class="allocation-legend-name">' + a.name + '</span>' +
        '<span class="allocation-legend-pct">' + a.pct + '%</span>';
      legend.appendChild(item);
    });
  }

  /* -----------------------------------------------------------------------
     Withdraw View
     ----------------------------------------------------------------------- */
  function populateWithdrawView() {
    const d = state.mockData;
    const balEl = $('#withdraw-balance');
    if (balEl) {
      balEl.innerHTML = 'Available to withdraw: ' + formatNumber(d.userValue, 2) + ' USDC<br>' +
        '<span style="font-size:11px;color:rgba(255,255,255,0.2)">(' + formatNumber(d.userShares, 2) + ' yrUSDC at ' + formatNumber(d.sharePrice, 4) + ' USDC/share)</span>';
    }
  }

  function setupWithdrawForm() {
    const input = $('#withdraw-amount');
    const btn = $('#withdraw-btn');
    const previewBurn = $('#withdraw-preview-burn');
    const previewReceive = $('#withdraw-preview-receive');
    const validation = $('#withdraw-validation');
    const inputContainer = input ? input.closest('.input-amount-container') : null;

    if (!input || !btn) return;

    input.addEventListener('input', () => {
      const raw = input.value.replace(/[^0-9.]/g, '');
      const val = parseFloat(raw) || 0;
      const d = state.mockData;
      let hasError = false;

      if (validation) {
        validation.textContent = '';
        validation.className = 'input-validation-msg';
      }

      if (previewBurn && val > 0) {
        const shares = val / d.sharePrice;
        previewBurn.textContent = '~' + formatNumber(shares, 2) + ' yrUSDC';
      } else if (previewBurn) {
        previewBurn.textContent = '--';
      }

      if (previewReceive && val > 0) {
        previewReceive.textContent = '~' + formatNumber(val, 2) + ' USDC';
      } else if (previewReceive) {
        previewReceive.textContent = '--';
      }

      if (val > d.userValue) {
        if (validation) {
          validation.textContent = 'You can withdraw up to ' + formatNumber(d.userValue, 2) + ' USDC.';
          validation.className = 'input-validation-msg input-validation-msg--error';
        }
        btn.disabled = true;
        hasError = true;
      } else if (val > 0) {
        btn.disabled = false;
      } else {
        btn.disabled = true;
      }

      // Toggle error border on input container per visual spec
      if (inputContainer) {
        inputContainer.classList.toggle('input-amount-container--error', hasError);
      }
    });

    // MAX
    const maxBtn = $('#withdraw-max');
    if (maxBtn) {
      maxBtn.addEventListener('click', () => {
        input.value = state.mockData.userValue.toFixed(2);
        input.dispatchEvent(new Event('input'));
      });
    }

    // Withdraw button
    btn.addEventListener('click', async () => {
      if (btn.disabled) return;
      const val = parseFloat(input.value) || 0;
      if (val <= 0) return;

      const originalText = btn.textContent;

      btn.disabled = true;
      btn.innerHTML = '<span class="spinner"></span> Confirm in wallet...';
      await delay(1500);

      btn.innerHTML = '<span class="spinner"></span> Withdrawing...';
      await delay(2000);

      btn.innerHTML = originalText;
      btn.disabled = true;

      const shares = val / state.mockData.sharePrice;
      showTxResult('withdraw', 'success',
        'Withdrew ' + formatNumber(val, 2) + ' USDC',
        formatNumber(shares, 2) + ' yrUSDC burned',
        '0xdef789...abc012'
      );

      input.value = '';
      input.dispatchEvent(new Event('input'));
    });
  }

  /* -----------------------------------------------------------------------
     Vault Info View
     ----------------------------------------------------------------------- */
  function populateVaultInfoView() {
    // Allocation in vault info
    populateAllocationBar('#vault-allocation-bar', '#vault-allocation-legend');
  }

  /* -----------------------------------------------------------------------
     FAQ Accordion
     ----------------------------------------------------------------------- */
  function setupFAQ() {
    $$('.faq-trigger').forEach((trigger) => {
      trigger.addEventListener('click', () => {
        const item = trigger.closest('.faq-item');
        const wasOpen = item.classList.contains('faq-item--open');

        // Close all and reset aria-expanded
        $$('.faq-item').forEach((fi) => {
          fi.classList.remove('faq-item--open');
          const t = $('.faq-trigger', fi);
          if (t) t.setAttribute('aria-expanded', 'false');
        });

        // Open this one if it was not open
        if (!wasOpen) {
          item.classList.add('faq-item--open');
          trigger.setAttribute('aria-expanded', 'true');
        }
      });
    });
  }

  /* -----------------------------------------------------------------------
     Tx Result Dismiss
     ----------------------------------------------------------------------- */
  function setupTxDismiss() {
    $$('.tx-result-dismiss').forEach((btn) => {
      btn.addEventListener('click', () => {
        const result = btn.closest('.tx-result');
        if (result) {
          result.classList.remove('visible');
          result.style.display = 'none';
        }
      });
    });
  }

  /* -----------------------------------------------------------------------
     Copy Address
     ----------------------------------------------------------------------- */
  function setupCopyButtons() {
    $$('[data-copy]').forEach((btn) => {
      btn.addEventListener('click', () => {
        const text = btn.dataset.copy;
        navigator.clipboard.writeText(text).then(() => {
          const original = btn.innerHTML;
          btn.innerHTML = '&#10003;';
          btn.style.color = '#10B981';
          setTimeout(() => {
            btn.innerHTML = original;
            btn.style.color = '';
          }, 1500);
        });
      });
    });
  }

  /* -----------------------------------------------------------------------
     Smooth Scroll
     ----------------------------------------------------------------------- */
  function setupSmoothScroll() {
    $$('[data-scroll]').forEach((btn) => {
      btn.addEventListener('click', (e) => {
        e.preventDefault();
        const target = document.getElementById(btn.dataset.scroll);
        if (target) {
          target.scrollIntoView({ behavior: 'smooth', block: 'start' });
        }
      });
    });
  }

  /* -----------------------------------------------------------------------
     Chart Range Buttons
     ----------------------------------------------------------------------- */
  function setupChartRange() {
    $$('.chart-range-btn').forEach((btn) => {
      btn.addEventListener('click', () => {
        $$('.chart-range-btn').forEach((b) => b.classList.remove('chart-range-btn--active'));
        btn.classList.add('chart-range-btn--active');
      });
    });
  }

  /* -----------------------------------------------------------------------
     Utilities
     ----------------------------------------------------------------------- */
  function delay(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }

  /* -----------------------------------------------------------------------
     Init
     ----------------------------------------------------------------------- */
  function init() {
    setupNavigation();
    setupWalletModal();
    setupDepositForm();
    setupWithdrawForm();
    setupFAQ();
    setupTxDismiss();
    setupCopyButtons();
    setupSmoothScroll();
    setupChartRange();

    // Landing page animations
    setupScrollAnimations();
    setupStatCountUp();

    // Make hero immediately visible
    const hero = $('.hero');
    if (hero) hero.classList.add('landing-section--visible');

    // Default view
    showView('landing');
  }

  // Run on DOM ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
