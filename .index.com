<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<title>Mascot Charm Generator | Lucky Misfits · Perspective Makers</title>
<link href="https://fonts.googleapis.com/css2?family=Fredoka+One&family=Nunito:wght@400;700;900&family=Boogaloo&display=swap" rel="stylesheet">
<!-- jsPDF: draws the PDF as real text (same library + version as CITYSCOPE and Seeds & Worms) -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
<style>
  *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

  :root {
    --bg:         #2a1a4a;
    --bg2:        #1e1038;
    --lime:       #c8f000;
    --pink:       #f03e8c;
    --pink-dark:  #c4006e;
    --yellow:     #ffe535;
    --teal:       #2cbfb0;
    --orange:     #ff7c2a;
    --cream:      #fffbe8;
    --white:      #ffffff;
    --card-bg:    #b8e000;
    --card-shadow:#d4006a;
    --dark-text:  #1a0a2e;
  }

  html { background-color: #1a0f33; color-scheme: dark; }
  html, body { min-height: 100%; }
  body {
    background-color: #1a0f33;
    min-height: 100vh;
    font-family: 'Nunito', sans-serif;
    color: var(--cream);
  }

  .page { max-width: 860px; margin: 0 auto; padding: 32px 20px 48px; }

  /* ── TOP BADGE ── */
  .top-badge { text-align: center; margin-bottom: 18px; }
  .top-badge span {
    display: inline-block; font-family: 'Fredoka One', cursive; font-size: 12px;
    letter-spacing: 0.18em; text-transform: uppercase; color: var(--cream);
    border: 2.5px solid var(--pink); border-radius: 100px; padding: 6px 20px;
    background: rgba(240,62,140,0.15);
  }

  /* ── HERO ── */
  .hero-title { text-align: center; margin-bottom: 10px; line-height: 0.92; }
  .hero-title .line1 {
    display: block; font-family: 'Fredoka One', cursive; font-size: clamp(46px, 11vw, 90px);
    color: var(--yellow);
    text-shadow: 4px 4px 0 #b35a00, -2px -2px 0 #b35a00, 2px -2px 0 #b35a00, -2px 2px 0 #b35a00, 0 6px 0 rgba(0,0,0,0.5);
    letter-spacing: -0.01em;
  }
  .hero-title .line2 {
    display: block; font-family: 'Fredoka One', cursive; font-size: clamp(40px, 9.5vw, 78px);
    color: var(--lime);
    text-shadow: 3px 3px 0 #4a6600, -2px -2px 0 #4a6600, 2px -2px 0 #4a6600, -2px 2px 0 #4a6600, 0 5px 0 rgba(0,0,0,0.5);
    letter-spacing: -0.01em;
  }
  .hero-tagline {
    text-align: center; font-family: 'Fredoka One', cursive; font-size: clamp(18px, 4vw, 26px);
    color: var(--orange); letter-spacing: 0.03em; margin-bottom: 6px; text-shadow: 2px 2px 0 rgba(0,0,0,0.25);
  }
  .hero-sub {
    text-align: center; font-family: 'Boogaloo', cursive; font-size: clamp(16px, 3.5vw, 22px);
    color: var(--teal); margin-bottom: 6px; letter-spacing: 0.02em;
  }
  .hero-byline {
    text-align: center; font-weight: 700; font-size: 11px; letter-spacing: 0.14em;
    text-transform: uppercase; color: rgba(255,251,232,0.45); margin-bottom: 22px;
  }
  .charm-row { text-align: center; font-size: 22px; margin-bottom: 28px; letter-spacing: 4px; opacity: 0.75; }

  /* ── MAIN CARD ── */
  .main-card {
    background: var(--card-bg); border-radius: 20px; box-shadow: 8px 8px 0 var(--card-shadow);
    padding: 28px 28px 32px; margin-bottom: 26px;
  }
  .card-eyebrow {
    font-family: 'Fredoka One', cursive; font-size: 12px; letter-spacing: 0.18em; text-transform: uppercase;
    color: var(--dark-text); opacity: 0.6; text-align: center; margin-bottom: 16px;
  }
  .filter-label { font-weight: 700; font-size: 14px; color: var(--dark-text); margin-bottom: 10px; }
  .filter-label .hint { font-weight: 400; opacity: 0.7; }
  .filter-grid { display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 20px; }
  .card-rule { border: none; border-top: 2px dashed rgba(26,10,46,0.2); margin: 4px 0 20px; }

  /* Pills (same feel as the S&W mood / humor buttons) */
  .pill-btn {
    font-family: 'Fredoka One', cursive; font-size: 13px; padding: 7px 16px; border-radius: 100px;
    border: 2.5px solid var(--dark-text); background: var(--white); color: var(--dark-text);
    cursor: pointer; transition: all 0.12s ease; user-select: none; box-shadow: 2px 2px 0 rgba(0,0,0,0.2);
  }
  .pill-btn:hover, .pill-btn.active {
    background: var(--pink); border-color: var(--pink-dark); color: var(--white);
    transform: translate(-1px, -1px); box-shadow: 3px 3px 0 rgba(0,0,0,0.25);
  }
  .pill-btn.purple:hover, .pill-btn.purple.active { background: #7c3aed; border-color: #5b21b6; }
  .pill-btn.dark {
    border-color: var(--yellow); background: rgba(26,10,46,0.82); color: var(--yellow);
  }
  .pill-btn.dark:hover, .pill-btn.dark.active { background: var(--yellow); color: var(--dark-text); border-color: var(--yellow); }

  .mode-row { display: flex; justify-content: center; gap: 10px; flex-wrap: wrap; margin-bottom: 8px; }
  .mode-note { text-align: center; font-size: 12.5px; font-weight: 700; color: rgba(26,10,46,0.62); margin-bottom: 20px; }

  /* ── OPTION CARDS (Lucky Misfits / Perspective Makers) ── */
  .opt-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin-bottom: 10px; }
  .opt-card {
    --accent: var(--orange); --accent-dark: #b34700;
    background: rgba(26,10,46,0.92); border: 3px solid rgba(255,251,232,0.12); border-radius: 16px;
    padding: 14px 14px 14px; box-shadow: 4px 4px 0 rgba(0,0,0,0.25); transition: all 0.15s ease;
  }
  .opt-card.persp { --accent: var(--teal); --accent-dark: #127a70; }
  .opt-card.on { border-color: var(--accent); box-shadow: 5px 5px 0 var(--accent-dark); }
  .opt-head {
    display: flex; gap: 10px; align-items: flex-start; width: 100%; text-align: left;
    background: none; border: none; cursor: pointer; color: var(--cream); padding: 2px 2px 10px;
  }
  .opt-check {
    flex: 0 0 26px; height: 26px; border-radius: 50%; border: 2.5px solid rgba(255,251,232,0.4);
    display: flex; align-items: center; justify-content: center; font-family: 'Fredoka One', cursive;
    font-size: 15px; color: transparent; margin-top: 2px; transition: all 0.12s ease;
  }
  .opt-card.on .opt-check { background: var(--accent); border-color: var(--accent); color: var(--dark-text); }
  .opt-name { font-family: 'Fredoka One', cursive; font-size: 21px; color: var(--accent); line-height: 1.1; }
  .opt-tag { font-family: 'Boogaloo', cursive; font-size: 16px; color: var(--cream); margin-top: 2px; }
  .opt-big { font-size: 12.5px; color: rgba(255,251,232,0.6); margin-top: 4px; line-height: 1.4; }
  .opt-idea {
    width: 100%; min-height: 96px; resize: vertical; font-family: 'Nunito', sans-serif; font-size: 16px;
    padding: 11px 13px; border-radius: 11px; border: none; background: var(--cream); color: var(--dark-text);
    outline: none; box-shadow: inset 0 2px 4px rgba(0,0,0,0.1); -webkit-text-size-adjust: 100%;
  }
  .opt-idea::placeholder { color: rgba(26,10,46,0.38); }
  .opt-idea:focus { box-shadow: inset 0 2px 4px rgba(0,0,0,0.1), 0 0 0 3px var(--accent); }
  .opt-off-note { font-size: 11.5px; color: rgba(255,251,232,0.45); margin-top: 6px; }
  .same-row { text-align: center; margin-bottom: 20px; }
  .link-btn {
    font-family: 'Nunito', sans-serif; font-weight: 900; font-size: 13px; background: none; border: none;
    color: var(--dark-text); text-decoration: underline; text-underline-offset: 3px; cursor: pointer; opacity: 0.75;
  }
  .link-btn:hover { opacity: 1; }

  .text-input {
    font-family: 'Nunito', sans-serif; font-size: 16px; width: 100%; padding: 12px 16px; border-radius: 12px;
    border: none; background: var(--cream); color: var(--dark-text); outline: none; margin-bottom: 20px;
    box-shadow: inset 0 2px 4px rgba(0,0,0,0.1); -webkit-text-size-adjust: 100%;
  }
  .text-input::placeholder { color: rgba(26,10,46,0.38); }
  .text-input:focus { box-shadow: inset 0 2px 4px rgba(0,0,0,0.1), 0 0 0 3px rgba(240,62,140,0.35); }

  .web-row { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; margin-bottom: 20px; }
  .web-note { font-size: 12.5px; font-weight: 700; color: rgba(26,10,46,0.62); line-height: 1.35; flex: 1; min-width: 200px; }

  /* ── GENERATE BUTTON ── */
  .generate-btn {
    font-family: 'Fredoka One', cursive; font-size: 22px; letter-spacing: 0.06em; width: 100%;
    padding: 18px 28px; border-radius: 14px; border: none; background: var(--pink); color: var(--white);
    cursor: pointer; box-shadow: 0 6px 0 var(--pink-dark); position: relative; top: 0;
    transition: all 0.1s ease; text-shadow: 1px 1px 0 rgba(0,0,0,0.25);
  }
  .generate-btn:hover:not(:disabled) { top: -3px; box-shadow: 0 9px 0 var(--pink-dark); }
  .generate-btn:active:not(:disabled) { top: 4px; box-shadow: 0 2px 0 var(--pink-dark); }
  .generate-btn:disabled { opacity: 0.55; cursor: not-allowed; top: 0; }

  .error-box {
    background: rgba(240,62,140,0.15); border: 2px solid var(--pink-dark); border-radius: 10px;
    padding: 12px 16px; margin-top: 14px; color: var(--dark-text); font-size: 14px; font-weight: 700; display: none;
  }
  .error-box.visible { display: block; }

  /* ── JOB STATUS (while a charm is being built) ── */
  .job-status {
    background: rgba(255,255,255,0.06); border: 2.5px dashed rgba(255,251,232,0.25); border-radius: 16px;
    padding: 18px 22px; margin-bottom: 16px;
  }
  .job-status .js-title { font-family: 'Fredoka One', cursive; font-size: 18px; color: var(--yellow); margin-bottom: 4px; }
  .job-status .js-step { font-family: 'Boogaloo', cursive; font-size: 17px; color: var(--teal); }
  .job-status .js-msg { font-size: 14px; color: rgba(255,251,232,0.6); margin-top: 2px; }
  .job-status .js-err { font-size: 14.5px; font-weight: 700; color: #ffb3d1; margin-top: 8px; display: none; }
  .bar { height: 4px; background: rgba(255,251,232,0.12); border-radius: 4px; overflow: hidden; margin-top: 12px; }
  .bar::after {
    content: ''; display: block; height: 100%; width: 40%; background: var(--pink); border-radius: 4px;
    animation: barScroll 1.2s ease-in-out infinite;
  }
  @keyframes barScroll { 0% { transform: translateX(-200%); } 100% { transform: translateX(400%); } }

  /* ── OUTPUT ── */
  #output-area { display: none; }
  #output-area.visible { display: block; animation: fadeUp 0.35s ease forwards; }
  @keyframes fadeUp { from { opacity: 0; transform: translateY(14px); } to { opacity: 1; transform: translateY(0); } }

  .jump-row { text-align: center; margin-bottom: 18px; font-family: 'Fredoka One', cursive; font-size: 13px; letter-spacing: 0.06em; color: rgba(255,251,232,0.5); }
  .jump-row a { color: var(--yellow); text-decoration: none; margin: 0 6px; }
  .jump-row a:hover { text-decoration: underline; }

  .charm-sheet { --accent: var(--orange); --accent2: var(--pink); margin-bottom: 34px; }
  .charm-sheet.persp { --accent: var(--teal); --accent2: var(--lime); }

  .charm-hero {
    background: linear-gradient(135deg, #2a1050 0%, #3d1a6e 50%, #5c2498 100%);
    border: 3px solid var(--accent); border-radius: 18px; padding: 24px 24px 22px; margin-bottom: 16px;
    box-shadow: 6px 6px 0 rgba(0,0,0,0.35);
  }
  .charm-name {
    font-family: 'Fredoka One', cursive; font-size: clamp(40px, 9vw, 64px); color: var(--yellow); line-height: 1;
    text-shadow: 3px 3px 0 #b35a00, 0 5px 0 rgba(0,0,0,0.4); margin: 4px 0 6px;
  }
  .charm-pron { font-family: 'Nunito', sans-serif; font-weight: 700; font-size: 13px; letter-spacing: 0.08em; color: rgba(255,251,232,0.5); }
  .charm-luck { font-family: 'Fredoka One', cursive; font-size: 20px; color: var(--accent); margin-top: 8px; }
  .charm-quick { font-family: 'Boogaloo', cursive; font-size: 24px; line-height: 1.3; color: var(--cream); margin-top: 10px; }
  .charm-motto { font-family: 'Nunito', sans-serif; font-weight: 900; font-size: 14px; letter-spacing: 0.04em; color: var(--lime); margin-top: 10px; }
  .charm-seed { font-size: 12px; color: rgba(255,251,232,0.45); margin-top: 10px; }

  .out-card {
    background: rgba(255,255,255,0.06); border: 2.5px solid rgba(255,251,232,0.15); border-radius: 16px;
    padding: 22px 24px 20px; margin-bottom: 16px;
  }
  .out-pill {
    display: inline-block; font-family: 'Fredoka One', cursive; font-size: 11px; letter-spacing: 1.6px;
    text-transform: uppercase; border-radius: 100px; padding: 4px 14px; border: 2px solid; margin-bottom: 8px;
  }
  .pill-teal { color: var(--teal); border-color: var(--teal); }
  .pill-pink { color: var(--pink); border-color: var(--pink); }
  .pill-yellow { color: var(--yellow); border-color: var(--yellow); }
  .pill-orange { color: var(--orange); border-color: var(--orange); }
  .pill-lime { color: var(--lime); border-color: var(--lime); }
  .pill-accent { color: var(--accent); border-color: var(--accent); }
  .out-title { font-family: 'Fredoka One', cursive; font-size: 22px; color: var(--cream); margin-bottom: 4px; line-height: 1.2; }
  .out-sub { font-family: 'Boogaloo', cursive; font-size: 14px; color: rgba(255,251,232,0.45); margin-bottom: 14px; }
  .out-body { font-size: 16px; color: var(--cream); line-height: 1.7; }
  .out-body p + p { margin-top: 10px; }
  .out-zap {
    background: rgba(0,0,0,0.3); border-left: 4px solid var(--accent); border-radius: 8px; padding: 11px 15px;
    margin-top: 14px; font-family: 'Boogaloo', cursive; font-size: 18px; color: var(--cream); line-height: 1.45;
  }
  .out-zap.big { font-family: 'Nunito', sans-serif; font-weight: 900; font-size: 18px; }
  .zap-label { font-family: 'Fredoka One', cursive; font-size: 9.5px; letter-spacing: 2px; text-transform: uppercase; opacity: 0.6; margin-bottom: 4px; }

  .fld-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 14px 20px; }
  .fld { min-width: 0; }
  .fld.wide { grid-column: 1 / -1; }
  .fld-k { font-family: 'Fredoka One', cursive; font-size: 10.5px; letter-spacing: 1.6px; text-transform: uppercase; color: var(--accent); margin-bottom: 3px; }
  .fld-v { font-size: 15.5px; line-height: 1.55; color: var(--cream); }
  .fld-v ul { padding-left: 18px; }
  .fld-v li + li { margin-top: 4px; }

  .palette { display: flex; flex-wrap: wrap; gap: 12px; margin-top: 4px; }
  .sw { display: flex; gap: 9px; align-items: center; min-width: 170px; flex: 1; }
  .sw-chip { flex: 0 0 38px; height: 38px; border-radius: 9px; border: 2px solid rgba(255,251,232,0.35); box-shadow: 2px 2px 0 rgba(0,0,0,0.3); }
  .sw-name { font-family: 'Fredoka One', cursive; font-size: 14px; color: var(--cream); }
  .sw-hex { font-size: 11.5px; letter-spacing: 0.06em; color: rgba(255,251,232,0.5); }
  .sw-where { font-size: 12.5px; color: rgba(255,251,232,0.7); line-height: 1.35; }

  .tag-row { display: flex; flex-wrap: wrap; gap: 7px; margin-top: 4px; }
  .tag {
    font-family: 'Fredoka One', cursive; font-size: 12px; letter-spacing: 0.06em; padding: 5px 12px;
    border-radius: 100px; border: 2px solid rgba(255,251,232,0.22); color: rgba(255,251,232,0.75);
  }

  .roots-item { padding: 10px 0; border-bottom: 1px dashed rgba(255,251,232,0.16); }
  .roots-item:last-child { border-bottom: none; }
  .roots-fact { font-size: 15.5px; line-height: 1.55; color: var(--cream); }
  .roots-insp { font-family: 'Boogaloo', cursive; font-size: 16px; color: var(--teal); margin-top: 3px; }
  .src-link { font-size: 12px; color: var(--yellow); word-break: break-all; text-decoration: none; }
  .src-link:hover { text-decoration: underline; }
  .badge {
    display: inline-block; font-family: 'Fredoka One', cursive; font-size: 10px; letter-spacing: 0.1em;
    text-transform: uppercase; padding: 2px 9px; border-radius: 100px; margin-left: 6px; vertical-align: middle;
  }
  .b-ok { background: var(--lime); color: var(--dark-text); }
  .b-warn { background: var(--yellow); color: var(--dark-text); }
  .b-bad { background: var(--pink); color: var(--white); }
  .b-mute { background: rgba(255,251,232,0.15); color: rgba(255,251,232,0.75); }
  .web-status { font-size: 13px; font-weight: 700; color: rgba(255,251,232,0.65); margin-bottom: 10px; }

  .nc-row { display: grid; grid-template-columns: 130px 1fr; gap: 10px; padding: 8px 0; border-bottom: 1px dashed rgba(255,251,232,0.14); }
  .nc-row:last-child { border-bottom: none; }
  .nc-name { font-family: 'Fredoka One', cursive; font-size: 16px; color: var(--cream); }
  .nc-found { font-size: 14px; color: rgba(255,251,232,0.75); line-height: 1.45; }
  .nc-wait { font-family: 'Boogaloo', cursive; font-size: 17px; color: var(--teal); }

  /* Quick sketches */
  .sketch-head { font-family: 'Fredoka One', cursive; font-size: 22px; color: var(--accent); margin: 6px 0 12px; }
  .sketch-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin-bottom: 30px; }
  .sketch {
    background: rgba(255,255,255,0.06); border: 2.5px solid rgba(255,251,232,0.15); border-radius: 16px;
    padding: 16px 18px; display: flex; flex-direction: column; gap: 6px;
  }
  .sketch .sk-name { font-family: 'Fredoka One', cursive; font-size: 24px; color: var(--yellow); line-height: 1.1; }
  .sketch .sk-luck { font-family: 'Fredoka One', cursive; font-size: 14px; color: var(--accent); }
  .sketch .sk-quick { font-family: 'Boogaloo', cursive; font-size: 18px; line-height: 1.3; }
  .sketch .sk-line { font-size: 14px; line-height: 1.45; color: rgba(255,251,232,0.8); }
  .sketch .sk-line b { font-family: 'Fredoka One', cursive; font-weight: normal; font-size: 10.5px; letter-spacing: 1.4px; text-transform: uppercase; color: var(--accent); margin-right: 4px; }
  .sketch .dev-btn {
    margin-top: auto; align-self: flex-start; font-family: 'Fredoka One', cursive; font-size: 14px;
    padding: 8px 16px; border-radius: 10px; border: 2.5px solid var(--accent); background: rgba(0,0,0,0.25);
    color: var(--accent); cursor: pointer; transition: all 0.12s ease;
  }
  .sketch .dev-btn:hover { background: var(--accent); color: var(--dark-text); }

  /* ── ACTION BUTTONS ── */
  .action-row { display: flex; gap: 10px; flex-wrap: wrap; margin-bottom: 8px; align-items: center; }
  .action-btn {
    font-family: 'Fredoka One', cursive; font-size: 15px; padding: 11px 22px; border-radius: 10px;
    border: 2.5px solid rgba(255,251,232,0.3); background: rgba(255,255,255,0.07); color: var(--cream);
    cursor: pointer; transition: all 0.12s ease; box-shadow: 0 4px 0 rgba(0,0,0,0.3); position: relative; top: 0;
  }
  .action-btn:hover { border-color: var(--yellow); color: var(--yellow); top: -2px; box-shadow: 0 6px 0 rgba(0,0,0,0.3); }
  .action-btn:active { top: 3px; box-shadow: 0 1px 0 rgba(0,0,0,0.3); }
  .action-btn:disabled { opacity: 0.5; cursor: not-allowed; }
  .paper-toggle { display: inline-flex; border: 2px solid rgba(255,251,232,0.25); border-radius: 100px; overflow: hidden; }
  .paper-toggle button {
    font-family: 'Fredoka One', cursive; font-size: 12px; letter-spacing: 0.06em; padding: 7px 12px;
    background: none; border: none; color: rgba(255,251,232,0.55); cursor: pointer;
  }
  .paper-toggle button.active { background: var(--yellow); color: var(--dark-text); }
  .copy-confirm { font-family: 'Fredoka One', cursive; font-size: 13px; color: #b8e000; letter-spacing: 0.08em; opacity: 0; transition: opacity 0.3s; }
  .copy-confirm.show { opacity: 1; }
  .out-error { font-size: 14px; font-weight: 700; color: #ffb3d1; margin-top: 8px; display: none; }

  /* ── FOOTER ── */
  .site-footer { text-align: center; padding-top: 24px; font-family: 'Fredoka One', cursive; font-size: 12px; letter-spacing: 0.1em; color: rgba(255,251,232,0.28); }
  .footer-tagline { display: inline-block; font-size: 15px; color: var(--orange); letter-spacing: 0.04em; margin-bottom: 10px; opacity: 0.85; }
  .site-footer a { color: var(--teal); text-decoration: none; transition: color 0.15s; }
  .site-footer a:hover { color: var(--yellow); }

  @media (max-width: 620px) {
    .main-card { padding: 20px 16px 24px; }
    .opt-grid, .sketch-grid, .fld-grid { grid-template-columns: 1fr; }
    .generate-btn { font-size: 18px; padding: 15px; }
    .action-row { flex-direction: column; align-items: stretch; }
    .nc-row { grid-template-columns: 1fr; gap: 2px; }
    .charm-hero, .out-card { padding: 18px 16px; }
  }
</style>
</head>
<body>

<div class="page">

  <div class="top-badge"><span>🍀 Lucky Misfits · Perspective Makers</span></div>

  <div class="hero-title">
    <span class="line1">MASCOT CHARM</span>
    <span class="line2">GENERATOR</span>
  </div>
  <p class="hero-tagline">Strange little creatures. Remarkably good intentions.</p>
  <p class="hero-sub">Good-luck mascots for life's imperfect adventures</p>
  <p class="hero-byline">Created by Quirky Flash Chronicles · Studio Bits of Gravity · MVANNP</p>
  <div class="charm-row">🌰 🪨 ☁️ 🐌 🍀 🌀 👁 🌱 ✨</div>

  <!-- ════════ INPUT CARD ════════ -->
  <div class="main-card">
    <div class="card-eyebrow">Build a good-luck charm to draw</div>

    <div class="mode-row" id="modeRow">
      <button class="pill-btn dark active" data-mode="full">✦ Full Charm</button>
      <button class="pill-btn dark" data-mode="quick">✎ Quick Sketches</button>
    </div>
    <div class="mode-note" id="modeNote">One finished concept per collection — name, what it does, folklore, and a full drawing brief.</div>

    <div class="filter-label">Pick one or both collections, then add your idea <span class="hint">(or leave the box blank and get surprised)</span></div>
    <div class="opt-grid">
      <div class="opt-card misfit on" id="optMisfits" data-key="misfits">
        <button class="opt-head" type="button">
          <span class="opt-check">✓</span>
          <span>
            <span class="opt-name">Lucky Misfits</span><br>
            <span class="opt-tag">Good luck for the beautifully imperfect.</span><br>
            <span class="opt-big">Flaws are their superpowers. You don't have to be perfect to be lucky.</span>
          </span>
        </button>
        <textarea class="opt-idea" id="ideaMisfits" maxlength="300"
          placeholder="Your Lucky Misfit idea… e.g. luck for first days · a pencil that's always too short · a button that never fits its hole"></textarea>
        <div class="opt-off-note" id="noteMisfits"></div>
      </div>

      <div class="opt-card persp" id="optPersp" data-key="persp">
        <button class="opt-head" type="button">
          <span class="opt-check">✓</span>
          <span>
            <span class="opt-name">Perspective Makers</span><br>
            <span class="opt-tag">Good luck is seeing what others overlook.</span><br>
            <span class="opt-big">Strange, symbolic creatures from science, nature, folklore and ordinary things.</span>
          </span>
        </button>
        <textarea class="opt-idea" id="ideaPersp" maxlength="300"
          placeholder="Your Perspective Maker idea… e.g. gravity · lichen · the dust in a sunbeam · the underside of a fallen leaf"></textarea>
        <div class="opt-off-note" id="notePersp"></div>
      </div>
    </div>
    <div class="same-row"><button class="link-btn" id="sameBtn" type="button">⇄ Use the same idea for both</button></div>

    <hr class="card-rule">

    <div class="filter-label">Made for <span class="hint">(optional)</span></div>
    <div class="filter-grid" id="forGrid">
      <button class="pill-btn active" data-for="Collectible series">🎴 Collectible series</button>
      <button class="pill-btn" data-for="A person">🧑 A person</button>
      <button class="pill-btn" data-for="A gift">🎁 A gift</button>
      <button class="pill-btn" data-for="A place or town">🏘 A place or town</button>
      <button class="pill-btn" data-for="A business or team">🏃 A business or team</button>
      <button class="pill-btn" data-for="An occasion">🎉 An occasion</button>
    </div>
    <input class="text-input" id="forText" type="text" maxlength="160"
      placeholder="Who or what is it for? (optional) e.g. my granddaughter starting kindergarten · Lawrenceville, GA · a running club">

    <div class="filter-label">Draw inspiration from <span class="hint">(pick any, or leave all off for a surprise mix)</span></div>
    <div class="filter-grid" id="inspoGrid">
      <button class="pill-btn purple" data-inspo="Seeds & plants">🌱 Seeds &amp; plants</button>
      <button class="pill-btn purple" data-inspo="Stones & minerals">🪨 Stones &amp; minerals</button>
      <button class="pill-btn purple" data-inspo="Weather & sky">☁️ Weather &amp; sky</button>
      <button class="pill-btn purple" data-inspo="Gravity & invisible forces">🌀 Gravity &amp; invisible forces</button>
      <button class="pill-btn purple" data-inspo="Light & time">💡 Light &amp; time</button>
      <button class="pill-btn purple" data-inspo="Tiny creatures & microbes">🐞 Tiny creatures</button>
      <button class="pill-btn purple" data-inspo="Folklore & superstition">🧿 Folklore</button>
      <button class="pill-btn purple" data-inspo="Everyday objects">📎 Everyday objects</button>
      <button class="pill-btn purple" data-inspo="Kitchen & home">🫖 Kitchen &amp; home</button>
      <button class="pill-btn purple" data-inspo="Ocean & shore">🐚 Ocean &amp; shore</button>
    </div>

    <div id="webWrap">
      <hr class="card-rule">
      <div class="web-row">
        <button class="pill-btn dark active" id="webBtn" type="button">🔎 Web check: ON</button>
        <div class="web-note" id="webNote">Grounds each charm in real science &amp; folklore with sources, and screens the name against existing characters. Adds about a minute.</div>
      </div>
    </div>

    <button class="generate-btn" id="generateBtn">🍀 MAKE THE CHARM! 🍀</button>
    <div class="error-box" id="errorBox"></div>
  </div>

  <!-- ════════ OUTPUT ════════ -->
  <div id="output-area">
    <div class="jump-row" id="jumpRow"></div>
    <div id="sheets"></div>

    <div class="action-row" id="actionRow">
      <button class="action-btn" id="againBtn">↺ Make Another</button>
      <button class="action-btn" id="copyBtn">⎘ Copy Text</button>
      <button class="action-btn" id="txtBtn">⬇ .txt</button>
      <button class="action-btn" id="pdfBtn">⬇ Download PDF</button>
      <span class="paper-toggle" id="paperToggle">
        <button data-paper="dark" class="active">Dark</button><button data-paper="light">Print-friendly</button>
      </span>
      <span class="copy-confirm" id="copyConfirm">✦ Copied!</span>
    </div>
    <div class="out-error" id="outError"></div>
  </div>

  <div class="site-footer">
    <span class="footer-tagline">You don't have to be perfect to be lucky.</span><br>
    Mascot Charm Generator · <a href="https://quirkyflashchronicles.com" target="_blank" rel="noopener">Quirky Flash Chronicles</a> · Studio Bits of Gravity<br>
    MVANNP
  </div>

</div><!-- /page -->

<script>
  const WORKER_URL = 'https://gravificer-proxy.mvphillips.workers.dev/';

  // ── MODELS ─────────────────────────────────────────────────────────
  // MODEL writes the charm (the creative part). Same model as the Seeds & Worms
  // Generator. Opus 5.5 thinks before it writes, and that thinking counts
  // against max_tokens -- which is why the writing ceiling is roomy.
  // RESEARCH_MODEL does the web searches + name screen. It's faster, which keeps
  // each search call well under Cloudflare's 100-second (524) limit.
  // To change a model, change ONLY these lines. Names: https://docs.claude.com/en/docs/about-claude/models
  const MODEL          = 'claude-opus-5-5';
  const RESEARCH_MODEL = 'claude-sonnet-4-6';
  const FALLBACK_MODEL = 'claude-sonnet-4-6';   // used once if the writing call times out
  const SEARCH_TOOL = { type: 'web_search_20250305', name: 'web_search', max_uses: 4 };
  const NAME_TOOL   = { type: 'web_search_20250305', name: 'web_search', max_uses: 3 };
  const TOKENS = { write: 8000, quick: 6000, research: 3000, names: 2000 };

  const COLLECTIONS = {
    misfits: { key: 'misfits', label: 'Lucky Misfits', one: 'Lucky Misfit', cls: 'misfit', emoji: '🍀' },
    persp:   { key: 'persp',   label: 'Perspective Makers', one: 'Perspective Maker', cls: 'persp', emoji: '👁' }
  };

  const state = {
    mode: 'full',
    on: { misfits: true, persp: false },
    madeFor: 'Collectible series',
    inspo: [],
    web: true,
    paper: 'dark',
    jobs: [],
    running: false
  };

  const $ = id => document.getElementById(id);

  /* ════════════════════════════════════════════════════
     SURPRISE DECKS — used only when an idea box is left blank.
     Shuffle-bags: nothing repeats until the whole deck is used.
     ════════════════════════════════════════════════════ */
  const DECKS = {
    misfitLuck: ['first days', 'persistence', 'bad days', 'second chances', 'happy accidents', 'trying something hard',
      'being the new kid', 'asking for help', 'starting over', 'saying sorry', 'getting lost', 'slow progress',
      'being different', 'making friends', 'big tests', 'long waits', 'homesickness', 'rainy weekends', 'letting go',
      'finishing what you started', 'speaking up', 'messy creativity', 'early mornings', 'learning to ride a bike'],
    misfitSource: ['an acorn', 'a mismatched button', 'a bent nail', 'a pencil stub', 'a cracked teacup', 'a lost sock',
      'a pebble', 'a bottle cap', 'a paperclip', 'a dandelion gone to seed', 'a crumpled map', 'a crayon nub',
      'a seed packet', 'a single mitten', 'a key with no lock', 'a spool of thread', 'a pine cone', 'a chipped marble',
      'a broken umbrella', 'an empty snail shell', 'a rubber band', 'a toast crust', 'a stray feather', 'a knotted shoelace'],
    perspPhenomenon: ['gravity', 'seed dormancy', 'lichen (two organisms living as one)', 'tree rings', 'bioluminescence',
      'magnetism and compasses', "tides and the moon's pull", 'spider silk', 'mycelium networks under the forest floor',
      'photosynthesis', 'bird migration', 'erosion slowly shaping stone', 'snowflake crystals', 'the spiral in a pinecone',
      'echoes', 'shadows and sundials', 'static electricity', 'moss surviving drought', 'fossils', 'rust and slow change',
      'condensation on a cold glass', 'ant trails', 'dust in a sunbeam', 'pollination', 'starlight that left long ago',
      'wild yeast in sourdough', 'surface tension and bubbles', 'the underside of a fallen leaf']
  };
  const bags = {};
  function shuffle(arr) { const a = arr.slice(); for (let i = a.length - 1; i > 0; i--) { const j = Math.floor(Math.random() * (i + 1)); [a[i], a[j]] = [a[j], a[i]]; } return a; }
  function draw(deck) { if (!bags[deck] || !bags[deck].length) bags[deck] = shuffle(DECKS[deck]); return bags[deck].pop(); }

  /* Names already used this browser — so the generator doesn't keep landing on the same ones. */
  function recentNames() { try { return JSON.parse(localStorage.getItem('charmNames') || '[]'); } catch (e) { return []; } }
  function rememberNames(list) {
    try {
      const all = recentNames().concat(list.filter(Boolean)).map(s => String(s).trim()).filter(Boolean);
      localStorage.setItem('charmNames', JSON.stringify(Array.from(new Set(all)).slice(-40)));
    } catch (e) {}
  }

  /* ════════════════════════════════════════════════════
     PROMPTS
     ════════════════════════════════════════════════════ */
  const COMMON = `You are designing an ORIGINAL good-luck mascot ("charm") for Morgan Phillips (signature MVANNP), a cartoonist and illustrator who will DRAW it by hand. Your job is the concept and a drawing brief — not the drawing.

Morgan's style: modern folk art + cartoon humor + a fascination with science and ordinary things. Handmade, slightly uneven, full of personality. Characters must read without any language — a child anywhere in the world should get it from the picture alone.

EVERY CHARM HAS ALL FIVE:
1. An unmistakable silhouette — recognizable as a tiny 1-inch sticker.
2. One deliberate imperfection — a crooked horn, mismatched feet, an eye somewhere unexpected.
3. One symbolic object or marking that identifies its particular kind of luck.
4. A simple visual personality — understood without words.
5. A tiny bit of folklore — an unusual origin, a peculiar behavior, and a small lucky ritual.

QUALITY BAR:
- Specific beats cute. Name real materials, real shapes, real behaviors ("its shell spirals the wrong way, so it only travels in loops"). Never vague magic ("radiates positive energy", "sprinkles luck", "spreads joy").
- Kill your first two ideas. The first idea is what anyone would make (a clover with eyes, a smiling star, a generic blob). Go past it.
- The luck must be EARNED by the concept: explain the mechanism — why THIS creature with THIS trait brings THIS kind of luck.
- No fortune-cookie wisdom. Rituals are tiny physical actions a person can actually do today. Thoughts are plain, warm, short.
- Vary the body plan. Not everything is a round blob with stubby legs — consider tall, flat, coiled, segmented, lopsided, hollow, many-legged, legless.
- No resemblance to existing famous characters, mascots or toys (Pokemon, Moomins, Totoro, Smurfs, Care Bears, Kirby, Sanrio, Muppets, etc.). A name must not be a famous name with a letter changed (e.g. "Wobbit" is too close to "Hobbit").
- Names: short, sayable aloud by a 6-year-old, invented-sounding, 1-3 syllables (a two-part name like "Drizzlewick" is fine).
- Plain, warm English. Short sentences. Facts must be true; if unsure, say so in second_look rather than stating it.`;

  const COLLECTION_BRIEF = {
    misfits: `COLLECTION: LUCKY MISFITS — "Good luck for the beautifully imperfect."
Big idea: You don't have to be perfect to be lucky.
Emotional appeal: companionship, humor, affection, encouragement. These charms make people feel better about themselves.
These creatures are not superheroes. They're not perfect. Most are spectacularly unqualified for the job they're supposed to do. Their imperfection isn't an obstacle to their luck — it's the SOURCE of it. The flaw must be the superpower, and you must show exactly how.
Blend these ingredients: Lucky Misfits (humor, imperfection, emotional connection) · Guardians of Ordinary Things (seeds, stones, buttons, pencils, everyday discoveries) · Almost-Real Creatures (imaginary species, peculiar habitats, unusual behaviors) · Modern Folk-Luck (symbolism, a good-luck ritual, collectible charm) · a small surprising lesson about seeing things differently.
Modern-folklore move: instead of a lucky rabbit's foot, a creature with three mismatched feet that stands for moving forward, however awkwardly.
Tone calibration only — do NOT reuse these names or concepts: Pipkin (luck for beginnings) was born from an acorn that fell in the wrong place and believes every mistake might be a planting opportunity; ritual: start one small thing. Grubble (luck for persistence) is a rock creature with extremely short legs who never gets anywhere quickly but always arrives; ritual: take one more step. Drizzlewick (luck for bad days) is a cloud who can't control the weather and carries a tiny umbrella for other people.
"luck_for" must read "Luck for ___". The LUCKY RITUAL is the headline takeaway.`,

    persp: `COLLECTION: PERSPECTIVE MAKERS — "Good luck is seeing what others overlook."
Big idea: Sometimes changing your perspective changes your luck.
Emotional appeal: curiosity, discovery, wonder, possibility. These charms help people see the world differently.
They don't promise to change anyone's fortune. They help people discover possibilities that were already there. They're defined by what they help people DISCOVER, not by their flaws. Each should feel like a cross between a discovered species, an ancient lucky charm, and a contemporary illustration — a creature that has always existed but nobody noticed until now. They don't have to be cute: strange, mysterious, funny, ancient-looking or slightly absurd are all welcome.
Blend these ingredients: Perspective (an unexpected way of looking at something familiar) · Science & nature (gravity, seeds, light, time, weather, natural phenomena) · Modern folk art (unusual shapes, symbolic markings, handmade character, visual simplicity) · Imaginary folklore (a believable origin, a peculiar behavior, a small personal ritual) · Good-luck symbolism (a possibility people want more of).
Visual vocabulary: symbolic anatomy (an eye where a heart should be, a body shaped like a seed, markings like orbital paths); nature shapes (roots, stones, shells, clouds, insects, stars, microscopic organisms); folk-art imperfections (hand-drawn contours, slightly uneven symmetry); limited colors — earthy tones with one unexpected bright accent.
The science must be REAL: build the creature on a true phenomenon and name it.
Mythology: they belong to the Unseen Keepers — tiny guardians of the extraordinary ordinary. They don't control luck; they help people recognize it.
Tone calibration only — do NOT reuse these names or concepts: Sprocket (hidden potential) lives inside seeds that haven't sprouted; lucky thought: small doesn't mean insignificant. Gravik (finding your center) is a tiny guardian of invisible forces who believes everything has a center. Chrono (the gift of time) carries a spiral shell that never stops growing; lucky thought: progress doesn't always move in a straight line.
"luck_for" is the possibility it guards, e.g. "Hidden Potential", "Seeing Differently". The LUCKY THOUGHT is the headline takeaway.`
  };

  function madeForBrief(madeFor, forText, hasPlaceResearch) {
    const who = forText ? ` Specifically: "${forText}".` : '';
    switch (madeFor) {
      case 'A person': return `MADE FOR: a personal good-luck character for one specific person or moment in their life.${who} Shape the luck, ritual and card_back around them.`;
      case 'A gift': return `MADE FOR: a gift someone gives to another person.${who} Write card_back as the note tucked in with it.`;
      case 'A place or town': return `MADE FOR: a guardian of a place, inspired by its landscape or an overlooked piece of local history.${who}` +
        (hasPlaceResearch ? ' Build ONLY on the verified place details in the research below — name them.' :
          ' No web research ran, so keep the place tint to atmosphere (light, plants, weather, general landscape). Do NOT state specific named local businesses, streets, people or history as fact; put any local specific you suggest into second_look so Morgan can verify it.');
      case 'A business or team': return `MADE FOR: a commissioned symbolic mascot for an organization — it stands for a quality they want more of (momentum, growth, courage, curiosity).${who} Make it something a team could rally around without it feeling corporate.`;
      case 'An occasion': return `MADE FOR: a specific occasion or event.${who}`;
      default: return `MADE FOR: an original collectible series — broad appeal, works for children internationally and still means something to adults.${who}`;
    }
  }

  function seedLine(job) {
    if (job.idea) return `MORGAN'S IDEA (build from this — honor it, then make it surprising): "${job.idea}"`;
    return `NO IDEA GIVEN — SURPRISE SEED (use it as the starting point): ${job.seed}`;
  }

  function inspoLine() {
    return state.inspo.length ? `LEAN ON THESE INSPIRATION SOURCES: ${state.inspo.join(', ')}.` : 'INSPIRATION: your choice — pick the most surprising fit.';
  }

  function avoidLine() {
    const names = recentNames();
    return names.length ? `NAMES ALREADY USED (do not reuse or echo these): ${names.join(', ')}.` : '';
  }

  function researchPrompt(job) {
    const C = COLLECTIONS[job.key];
    const place = state.madeFor === 'A place or town' && state.forText;
    return `You are a research assistant for an illustrator designing an ORIGINAL good-luck mascot. Use web search to find REAL, verifiable material — you are not designing the mascot.

Collection: ${C.label} (${job.key === 'misfits' ? 'quirky, lovable creatures whose flaws are their superpowers' : 'strange, symbolic creatures inspired by science, nature, folklore and ordinary things that help people see differently'})
${job.idea ? 'Idea: "' + job.idea + '"' : 'Starting seed: ' + job.seed}
Made for: ${state.madeFor}${state.forText ? ' — "' + state.forText + '"' : ''}
${state.inspo.length ? 'Inspiration sources: ' + state.inspo.join(', ') : ''}

FIND:
1. 3-4 TRUE facts from science, nature, or the history of everyday objects connected to the idea that could inspire a creature's anatomy, behavior, habitat or ritual. Prefer surprising, specific, drawable facts (a measurement, a behavior, a mechanism) over general ones.
2. 1-2 real luck traditions, superstitions or folk customs (any culture) connected to the idea, described respectfully and accurately.
3. Crowded territory: well-known existing characters, mascots, toys or brands that already own this idea, so the design can steer clear.${place ? `
4. 2-3 real, specific, overlooked details of "${state.forText}" (landscape, a local plant or animal, a piece of local history, a local object) — only things the search results actually show.` : ''}

RULES: Report only what the search results support. Every item needs the URL of the page that supports it. If you can't verify something, leave it out. 1-2 sentences per item. Use at most 4 searches.

Return ONLY this JSON, no other text:
{"facts":[{"fact":"","inspires":"how it could shape the creature","url":"","source":"site name"}],
 "traditions":[{"tradition":"","url":"","source":""}],
 "crowded":[{"name":"","what":"","url":""}]${place ? `,
 "place":[{"detail":"","url":"","source":""}]` : ''}}`;
  }

  function researchBlock(r) {
    if (!r) return `NO WEB RESEARCH RAN. real_roots may use well-established general knowledge only; set every src to "" and list anything you're less than certain of in second_look.`;
    const lines = [];
    r.facts.forEach((f, i) => lines.push(`F${i + 1}. ${f.fact} [inspires: ${f.inspires || '-'}] (url: ${f.url})`));
    r.traditions.forEach((t, i) => lines.push(`T${i + 1}. ${t.tradition} (url: ${t.url})`));
    r.place.forEach((p, i) => lines.push(`P${i + 1}. ${p.detail} (url: ${p.url})`));
    const crowded = r.crowded.map(c => c.name + (c.what ? ' (' + c.what + ')' : '')).join('; ');
    return `VERIFIED WEB RESEARCH — build on it. real_roots must come ONLY from these items, with their url copied into src. Do not present any other fact as verified.
${lines.join('\n') || '(searches found nothing usable — treat as no research)'}
${crowded ? 'CROWDED TERRITORY — steer the design and name clear of: ' + crowded : ''}`;
  }

  function fullPrompt(job, research) {
    const persp = job.key === 'persp';
    return `${COMMON}

${COLLECTION_BRIEF[job.key]}

${madeForBrief(state.madeFor, state.forText, !!(research && research.place.length))}
${inspoLine()}
${seedLine(job)}
${avoidLine()}

${researchBlock(research)}

Return ONLY this JSON (no code fences, no other text). Keep every field tight — this is a brief an illustrator reads at the drawing table.
{
 "collection": "${COLLECTIONS[job.key].label}",
 "name": "",
 "pronunciation": "e.g. PIP-kin",
 "luck_for": "",
 "quick": "What it does, in one sentence under 20 words.",
 "motto": "Its charm motto, under 8 words.",
 "what_it_does": ["2 short paragraphs (40-70 words each): what it does, for whom, and the mechanism of its luck"],
 ${persp
   ? `"perspective": "the new way of seeing it gives you, 1-2 sentences",
 "overlooked": "the specific ordinary thing it notices that everyone walks past",`
   : `"flaw": "its one endearing flaw, concrete",
 "superpower": "exactly how that flaw IS the source of its luck, 1-2 sentences",`}
 "origin": "folklore origin, 1-2 sentences",
 "habitat": "where it lives, specific",
 "behavior": "one peculiar, funny or strange behavior",
 "lucky_ritual": "tiny real action, imperative, under 10 words",
 "lucky_thought": "under 10 words",
 "carry_when": "the moments and people it's for, one sentence",
 "draw": {
   "silhouette": "the shape that reads at 1 inch",
   "imperfection": "the one deliberate imperfection",
   "symbol": "the symbolic object or marking and what it means",
   "body": "anatomy, materials, texture",
   "face": "eyes and expression",
   "scale": "how big, compared to a real object",
   "palette": [{"name":"","hex":"#rrggbb","where":"where it goes on the creature"}],
   "wordless": "how a child anywhere understands it with no words",
   "sticker_test": "what must survive at sticker size",
   "poses": ["3 pose or scene ideas, one line each"],
   "avoid": "what NOT to draw so it doesn't go generic or look like an existing character"
 },
 "card_back": "lucky postcard text, 25-45 words, warm, ends on the ritual or thought",
 "products": ["3 product ideas, each specific to THIS charm (e.g. an enamel pin where the crooked horn is a raised gold line)"],
 "family_dna": "the visual traits siblings in this collection should share",
 "siblings": [{"name":"","luck":"one line"}],
 "alt_names": ["3 alternate names"],
 "real_roots": [{"fact":"the true fact it's built on","inspires":"what it shaped","src":"url or empty"}],
 "second_look": ["anything Morgan should double-check before using"]
}
COUNTS: palette 3-4 (earthy plus one bright accent), poses 3, products 3, siblings 2, alt_names 3, real_roots 1-3, second_look 0-3.`;
  }

  function quickPrompt(job) {
    const persp = job.key === 'persp';
    return `${COMMON}

${COLLECTION_BRIEF[job.key]}

${madeForBrief(state.madeFor, state.forText, false)}
${inspoLine()}
${seedLine(job)}
${avoidLine()}

QUICK SKETCH MODE: give 5 rough, DIFFERENT concepts to choose from — different kinds of luck, different source materials, different body plans. Each one should make Morgan want to grab a pencil.

Return ONLY this JSON (no code fences):
{"sketches":[{"name":"","luck_for":"","quick":"what it does, under 18 words","hook":"${persp ? 'what it helps you see, one line' : 'the flaw and how it is the superpower, one line'}","look":"its silhouette and one key visual detail, one line","line":"${persp ? 'lucky thought' : 'lucky ritual'}, under 10 words"}]}`;
  }

  function namePrompt(job, c) {
    const names = [c.name].concat(c.alt_names || []).filter(Boolean).slice(0, 4);
    return `Quick screen: are these invented mascot names already used by well-known characters, mascots, toys, games, children's books, or brands?
Names: ${names.join(', ')}
Context: an original good-luck mascot (${COLLECTIONS[job.key].one}) — "${c.quick}"

Use web search (at most 3 searches; you may check several names in one search). Return ONLY this JSON:
{"results":[{"name":"","status":"clear|similar|taken","found":"what you found, one sentence; empty if clear","url":""}],"best":"the strongest name that is clear","note":"one sentence"}
clear = no notable character, mascot or brand found. similar = a minor or loosely related use exists. taken = a notable character, mascot, toy line or brand already uses it. This is a quick screen, not legal clearance.`;
  }

  /* ════════════════════════════════════════════════════
     WORKER CALLS — lessons from CITYSCOPE / FIELDSCOPE / Brand Signals:
     - clear messages for 524/504 timeouts and unreachable Worker
     - pause_turn: if a search pauses mid-turn, hand its work back and continue
     - stop_reason max_tokens: flagged so we retry instead of showing junk
     ════════════════════════════════════════════════════ */
  async function post(body) {
    let res;
    try {
      res = await fetch(WORKER_URL, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) });
    } catch (e) {
      const err = new Error('Could not reach the Worker — check your connection and try again.');
      err.network = true; throw err;
    }
    if (!res.ok) {
      if (res.status === 524 || res.status === 504) { const e = new Error('the request timed out (' + res.status + ')'); e.timeout = true; throw e; }
      const e = await res.json().catch(() => ({}));
      throw new Error((e.error && e.error.message) || ('Worker returned ' + res.status));
    }
    return res.json();
  }

  async function ask(body) {
    let messages = body.messages.slice(), all = [], last = null;
    for (let round = 0; round < 4; round++) {
      last = await post(Object.assign({}, body, { messages }));
      const content = last.content || [];
      all = all.concat(content);
      if (last.stop_reason === 'pause_turn') { messages = messages.concat([{ role: 'assistant', content }]); continue; }
      break;
    }
    return { last, all };
  }

  const textOf = blocks => (blocks || []).filter(b => b && b.type === 'text').map(b => b.text || '').join('');

  // Ask and parse JSON. Throws (with .truncated) if the reply was cut off and can't be read.
  async function askJSON(body, isGood) {
    const r = await ask(body);
    let parsed = parseJSON(textOf(r.last && r.last.content));
    if (!parsed || (isGood && !isGood(parsed))) parsed = parseJSON(textOf(r.all)) || parsed;
    if (!parsed || (isGood && !isGood(parsed))) {
      const e = new Error(r.last && r.last.stop_reason === 'max_tokens' ? 'the reply ran out of room (max_tokens)' : 'the reply came back unreadable');
      e.truncated = true; throw e;
    }
    return { data: parsed, all: r.all };
  }

  function normUrl(u) { return String(u || '').trim().replace(/^https?:\/\//i, '').replace(/^www\./i, '').replace(/[#?].*$/, '').replace(/\/+$/, '').toLowerCase(); }
  const domainOf = u => normUrl(u).split('/')[0];
  function domainsSeen(blocks) {
    const set = new Set();
    (blocks || []).forEach(b => {
      if (!b) return;
      if (b.type === 'web_search_tool_result' && Array.isArray(b.content)) b.content.forEach(r => { if (r && r.url) set.add(domainOf(r.url)); });
      if (Array.isArray(b.citations)) b.citations.forEach(c => { if (c && c.url) set.add(domainOf(c.url)); });
    });
    return set;
  }

  /* PARSE-START */
  // Escapes raw line breaks inside JSON strings (search replies sometimes contain them).
  function fixCtrl(s) {
    let out = '', inStr = false, esc = false;
    for (const c of s) {
      if (inStr) {
        if (esc) { esc = false; out += c; continue; }
        if (c === '\\') { esc = true; out += c; continue; }
        if (c === '"') { inStr = false; out += c; continue; }
        if (c === '\n') { out += '\\n'; continue; }
        if (c === '\r') continue;
        if (c === '\t') { out += '\\t'; continue; }
        out += c;
      } else { if (c === '"') inStr = true; out += c; }
    }
    return out;
  }
  // Finds the JSON even inside code fences or chatter; repairs trailing commas;
  // and rescues a truncated reply by cutting to the last complete element and closing brackets.
  function parseJSON(raw) {
    if (!raw) return null;
    let s = String(raw).replace(/```json/gi, '').replace(/```/g, '').trim();
    const a = s.indexOf('{');
    if (a === -1) return null;
    s = fixCtrl(s.slice(a));
    const tryParse = t => { try { return JSON.parse(t); } catch (e) { try { return JSON.parse(t.replace(/,\s*([}\]])/g, '$1')); } catch (e2) { return null; } } };
    const b = s.lastIndexOf('}');
    if (b !== -1) { const strict = tryParse(s.slice(0, b + 1)); if (strict) return strict; }
    // Truncated reply: collect every safe cut point (just after a } or ], or just before a comma),
    // then walk back from the latest one, closing open brackets, until one parses.
    const cuts = []; let inStr = false, esc = false;
    for (let i = 0; i < s.length; i++) {
      const c = s[i];
      if (inStr) { if (esc) esc = false; else if (c === '\\') esc = true; else if (c === '"') inStr = false; continue; }
      if (c === '"') { inStr = true; continue; }
      if (c === '}' || c === ']') cuts.push(i + 1);
      else if (c === ',') cuts.push(i);
    }
    for (let n = cuts.length - 1, tries = 0; n >= 0 && tries < 60; n--, tries++) {
      const end = cuts[n], st = []; let is = false, es = false;
      for (let i = 0; i < end; i++) {
        const c = s[i];
        if (is) { if (es) es = false; else if (c === '\\') es = true; else if (c === '"') is = false; continue; }
        if (c === '"') { is = true; continue; }
        if (c === '{' || c === '[') st.push(c === '{' ? '}' : ']');
        else if (c === '}' || c === ']') { if (st.length) st.pop(); }
      }
      let cand = s.slice(0, end).replace(/,\s*$/, '');
      for (let k = st.length - 1; k >= 0; k--) cand += st[k];
      const rec = tryParse(cand); if (rec) return rec;
    }
    return null;
  }
  /* PARSE-END */

  /* ════════════════════════════════════════════════════
     NORMALIZE — every field read defensively, so a renamed or
     missing field from the model never blanks the page or the PDF.
     ════════════════════════════════════════════════════ */
  function pick(o, keys) {
    if (!o || typeof o !== 'object') return undefined;
    for (const k of keys) { if (o[k] !== null && o[k] !== undefined && o[k] !== '') return o[k]; }
    return undefined;
  }
  const str = v => v == null ? '' : (typeof v === 'string' ? v.trim() : (Array.isArray(v) ? v.map(str).filter(Boolean).join(' ') : (typeof v === 'object' ? str(pick(v, ['text', 'name', 'n', 'fact', 'line', 'idea', 'value'])) : String(v))));
  const list = v => Array.isArray(v) ? v.filter(x => x != null && x !== '') : (v ? (typeof v === 'string' ? v.split(/\n+/).map(s => s.replace(/^[-•*\d.\s]+/, '').trim()).filter(Boolean) : [v]) : []);
  const strList = v => list(v).map(str).filter(Boolean);

  function normCharm(d, key) {
    d = d || {};
    const dr = pick(d, ['draw', 'drawing', 'drawing_brief', 'design', 'visual']) || {};
    const paras = list(pick(d, ['what_it_does', 'whatItDoes', 'description', 'detailed', 'details'])).map(str).filter(Boolean);
    return {
      key,
      collection: COLLECTIONS[key].label,
      name: str(pick(d, ['name', 'charm_name', 'title'])) || 'Unnamed Charm',
      pronunciation: str(pick(d, ['pronunciation', 'pronounce', 'say_it'])),
      luck_for: str(pick(d, ['luck_for', 'luckFor', 'luck', 'luck_type', 'theme'])),
      quick: str(pick(d, ['quick', 'one_liner', 'short', 'quick_description', 'summary'])),
      motto: str(pick(d, ['motto', 'tagline', 'slogan'])),
      what_it_does: paras,
      flaw: str(pick(d, ['flaw', 'imperfection_story'])),
      superpower: str(pick(d, ['superpower', 'flaw_superpower', 'why_its_lucky'])),
      perspective: str(pick(d, ['perspective', 'way_of_seeing', 'lens'])),
      overlooked: str(pick(d, ['overlooked', 'notices', 'overlooked_thing'])),
      origin: str(pick(d, ['origin', 'folklore', 'origin_story'])),
      habitat: str(pick(d, ['habitat', 'lives', 'home'])),
      behavior: str(pick(d, ['behavior', 'behaviour', 'peculiar_behavior', 'habit'])),
      lucky_ritual: str(pick(d, ['lucky_ritual', 'ritual', 'luckyRitual'])),
      lucky_thought: str(pick(d, ['lucky_thought', 'thought', 'luckyThought'])),
      carry_when: str(pick(d, ['carry_when', 'when_to_carry', 'for_whom', 'who_its_for'])),
      draw: {
        silhouette: str(pick(dr, ['silhouette', 'shape'])),
        imperfection: str(pick(dr, ['imperfection', 'deliberate_imperfection', 'flaw'])),
        symbol: str(pick(dr, ['symbol', 'symbolic_mark', 'marking', 'symbolic_object'])),
        body: str(pick(dr, ['body', 'anatomy', 'materials'])),
        face: str(pick(dr, ['face', 'expression', 'eyes'])),
        scale: str(pick(dr, ['scale', 'size'])),
        palette: list(pick(dr, ['palette', 'colors', 'colours'])).map(p => typeof p === 'string'
          ? { name: p.replace(/#[0-9a-f]{3,6}/i, '').replace(/[()\-:–—]+\s*$/, '').trim(), hex: (p.match(/#[0-9a-f]{6}|#[0-9a-f]{3}/i) || [''])[0], where: '' }
          : { name: str(pick(p, ['name', 'color', 'n'])), hex: str(pick(p, ['hex', 'code'])), where: str(pick(p, ['where', 'use', 'note'])) }),
        wordless: str(pick(dr, ['wordless', 'wordless_read', 'universal'])),
        sticker_test: str(pick(dr, ['sticker_test', 'sticker', 'small_size'])),
        poses: strList(pick(dr, ['poses', 'pose_ideas', 'thumbnails', 'scenes'])),
        avoid: str(pick(dr, ['avoid', 'dont', 'do_not']))
      },
      card_back: str(pick(d, ['card_back', 'cardBack', 'postcard', 'card_text'])),
      products: strList(pick(d, ['products', 'product_ideas', 'merch'])),
      family_dna: str(pick(d, ['family_dna', 'familyDNA', 'visual_dna', 'family'])),
      siblings: list(pick(d, ['siblings', 'family_members', 'sibling_ideas'])).map(s => typeof s === 'string'
        ? { name: s.split(/\s[—–-]\s|:/)[0].trim(), luck: s.split(/\s[—–-]\s|:/).slice(1).join(' ').trim() }
        : { name: str(pick(s, ['name', 'n'])), luck: str(pick(s, ['luck', 'luck_for', 'what', 'd'])) }).filter(s => s.name),
      alt_names: strList(pick(d, ['alt_names', 'alternate_names', 'altNames', 'other_names'])),
      real_roots: list(pick(d, ['real_roots', 'roots', 'real_facts', 'science'])).map(r => typeof r === 'string'
        ? { fact: r, inspires: '', src: '' }
        : { fact: str(pick(r, ['fact', 'text', 'n'])), inspires: str(pick(r, ['inspires', 'shaped', 'use'])), src: str(pick(r, ['src', 'url', 'source'])) }).filter(r => r.fact),
      second_look: strList(pick(d, ['second_look', 'verify', 'double_check', 'check']))
    };
  }
  const hasCharmCore = d => !!(d && pick(d, ['name', 'charm_name', 'title']) && (pick(d, ['quick', 'one_liner', 'summary']) || pick(d, ['what_it_does', 'description'])));

  function cleanResearch(r, seen) {
    const ok = u => /^https?:\/\//i.test(u || '') && seen.has(domainOf(u));
    const facts = list(r && r.facts).map(f => ({ fact: str(pick(f, ['fact', 'text'])), inspires: str(pick(f, ['inspires', 'use'])), url: str(pick(f, ['url', 'src'])), source: str(f && f.source) })).filter(f => f.fact && ok(f.url));
    const traditions = list(r && r.traditions).map(t => ({ tradition: str(pick(t, ['tradition', 'text', 'custom'])), url: str(pick(t, ['url', 'src'])), source: str(t && t.source) })).filter(t => t.tradition && ok(t.url));
    const place = list(r && r.place).map(p => ({ detail: str(pick(p, ['detail', 'text'])), url: str(pick(p, ['url', 'src'])), source: str(p && p.source) })).filter(p => p.detail && ok(p.url));
    const crowded = list(r && r.crowded).map(c => ({ name: str(pick(c, ['name'])), what: str(pick(c, ['what', 'note'])), url: ok(str(c && c.url)) ? str(c.url) : '' })).filter(c => c.name);
    return { facts, traditions, place, crowded, seen };
  }

  /* ════════════════════════════════════════════════════
     RUN
     ════════════════════════════════════════════════════ */
  const STEP_MSGS = {
    research: ['Digging through real science…', 'Checking old folklore…', 'Looking under leaves and in pockets…', 'Seeing who already owns this idea…', 'Collecting sources…'],
    write: ['Killing the first two ideas…', 'Finding the flaw that works…', 'Sketching the silhouette in words…', 'Inventing the folklore…', 'Writing the lucky ritual…', 'Picking the palette…'],
    quick: ['Filling the sketchbook…', 'Trying different body plans…', 'Naming the strange little things…']
  };

  function makeJobs() {
    const jobs = [];
    ['misfits', 'persp'].forEach(key => {
      if (!state.on[key]) return;
      const idea = $(key === 'misfits' ? 'ideaMisfits' : 'ideaPersp').value.trim();
      let seed = '';
      if (!idea) seed = key === 'misfits'
        ? `luck for ${draw('misfitLuck')}, from ${draw('misfitSource')}`
        : `${draw('perspPhenomenon')}`;
      jobs.push({ key, idea, seed, mode: state.mode, status: 'pending', charm: null, sketches: null, research: null, webNote: '', names: null, namesState: 'none', note: '' });
    });
    return jobs;
  }

  async function generate() {
    if (state.running) return;
    hideError();
    state.forText = $('forText').value.trim();
    if (!state.on.misfits && !state.on.persp) { showError('Pick at least one collection — Lucky Misfits, Perspective Makers, or both.'); return; }
    if (state.madeFor === 'A place or town' && !state.forText) { showError('Type the place or town in the "Who or what is it for?" box.'); return; }

    state.running = true;
    $('generateBtn').disabled = true;
    state.jobs = makeJobs();
    const out = $('output-area');
    $('sheets').innerHTML = '';
    $('outError').style.display = 'none';
    $('actionRow').style.display = 'none';
    state.jobs.forEach(job => {
      const el = document.createElement('div');
      el.id = 'job-' + job.key;
      el.innerHTML = statusHTML(job);
      $('sheets').appendChild(el);
      job.el = el;
    });
    renderJump();
    out.classList.add('visible');
    out.scrollIntoView({ behavior: 'smooth', block: 'start' });

    await Promise.all(state.jobs.map(job => (job.mode === 'quick' ? runQuick(job) : runFull(job)).catch(err => jobFailed(job, err))));

    state.running = false;
    $('generateBtn').disabled = false;
    const anyFull = state.jobs.some(j => j.charm);
    $('actionRow').style.display = state.jobs.some(j => j.charm || j.sketches) ? 'flex' : 'none';
    ['copyBtn', 'txtBtn', 'pdfBtn'].forEach(id => { $(id).style.display = anyFull ? '' : 'none'; });
    $('paperToggle').style.display = anyFull ? '' : 'none';
    renderJump();
  }

  function statusHTML(job) {
    const C = COLLECTIONS[job.key];
    return `<div class="job-status">
      <div class="js-title">${C.emoji} ${esc(C.one)}${job.idea ? ' · ' + esc(job.idea.slice(0, 70)) + (job.idea.length > 70 ? '…' : '') : ' · surprise seed: ' + esc(job.seed)}</div>
      <div class="js-step">Getting started…</div>
      <div class="js-msg"></div>
      <div class="bar"></div>
      <div class="js-err"></div>
    </div>`;
  }

  function setStep(job, step, msgs) {
    if (!job.el) return;
    const s = job.el.querySelector('.js-step'), m = job.el.querySelector('.js-msg');
    if (!s) return;
    s.textContent = step;
    clearInterval(job.timer);
    let i = 0; m.textContent = msgs[0];
    job.timer = setInterval(() => { i++; m.textContent = msgs[i % msgs.length]; }, 2400);
  }

  function jobFailed(job, err) {
    clearInterval(job.timer);
    job.status = 'failed';
    const msg = err && err.timeout ? 'It took too long and timed out. Tap Make the Charm again — or turn Web check off for a faster run.'
      : (err && err.message ? err.message : 'Something went wrong.');
    if (job.el) {
      const box = job.el.querySelector('.js-err'), bar = job.el.querySelector('.bar'), s = job.el.querySelector('.js-step');
      if (bar) bar.style.display = 'none';
      if (s) s.textContent = 'This one didn\'t finish.';
      if (box) { box.textContent = 'Couldn\'t build it — ' + msg; box.style.display = 'block'; }
      const m = job.el.querySelector('.js-msg'); if (m) m.textContent = '';
    }
  }

  async function runFull(job) {
    const C = COLLECTIONS[job.key];
    // PASS 1 — research with web search. If it fails, the charm still gets written (and says so).
    if (state.web) {
      setStep(job, 'Step 1 of 2 · Researching real roots', STEP_MSGS.research);
      try {
        const r = await askJSON({ model: RESEARCH_MODEL, max_tokens: TOKENS.research, tools: [SEARCH_TOOL], messages: [{ role: 'user', content: researchPrompt(job) }] });
        job.research = cleanResearch(r.data, domainsSeen(r.all));
        const n = job.research.facts.length + job.research.traditions.length + job.research.place.length;
        job.webNote = n ? `Web-checked · ${n} verified item${n === 1 ? '' : 's'} from ${job.research.seen.size} site${job.research.seen.size === 1 ? '' : 's'}`
          : 'Searched the web but found nothing solid enough to cite — real roots below are from general knowledge.';
        if (!n) job.research = Object.assign(job.research, { empty: true });
      } catch (e) {
        job.research = null;
        job.webNote = 'Web research didn\'t finish (' + e.message + ') — this charm was built from general knowledge. Check the real roots before using them.';
      }
    } else {
      job.webNote = 'Web check was off — real roots are from general knowledge. Verify before using.';
    }

    // PASS 2 — write the charm (no tools, full token budget). One retry; a timeout retries on the faster model.
    setStep(job, (state.web ? 'Step 2 of 2 · ' : '') + 'Designing your ' + C.one, STEP_MSGS.write);
    const research = job.research && !job.research.empty ? job.research : null;
    const body = { model: MODEL, max_tokens: TOKENS.write, messages: [{ role: 'user', content: fullPrompt(job, research) }] };
    let res;
    try { res = await askJSON(body, hasCharmCore); }
    catch (e1) {
      if (e1.timeout) {
        setStep(job, 'Timed out — retrying on the faster model', STEP_MSGS.write);
        res = await askJSON(Object.assign({}, body, { model: FALLBACK_MODEL }), hasCharmCore);
        job.note = 'Written by the faster backup model after a timeout.';
      } else {
        setStep(job, 'Second try…', STEP_MSGS.write);
        res = await askJSON(body, hasCharmCore);
      }
    }
    clearInterval(job.timer);
    job.charm = normCharm(res.data, job.key);
    // Only links to sites the research actually visited are kept as sources.
    if (research) job.charm.real_roots.forEach(r => { if (r.src && !(research.seen.has(domainOf(r.src)))) r.src = ''; });
    else job.charm.real_roots.forEach(r => { r.src = ''; });
    rememberNames([job.charm.name].concat(job.charm.alt_names));
    job.status = 'done';
    job.namesState = state.web ? 'checking' : 'off';
    job.el.innerHTML = charmHTML(job);
    wireSheet(job);

    // PASS 3 — screen the name (runs after the charm is on screen).
    if (state.web) runNameCheck(job);
  }

  async function runNameCheck(job) {
    try {
      const r = await askJSON({ model: RESEARCH_MODEL, max_tokens: TOKENS.names, tools: [NAME_TOOL], messages: [{ role: 'user', content: namePrompt(job, job.charm) }] },
        d => Array.isArray(d.results));
      const seen = domainsSeen(r.all);
      job.names = {
        results: list(r.data.results).map(x => ({
          name: str(pick(x, ['name'])), status: (str(pick(x, ['status'])) || 'clear').toLowerCase(),
          found: str(pick(x, ['found', 'note'])), url: (str(x && x.url) && seen.has(domainOf(x.url))) ? str(x.url) : ''
        })).filter(x => x.name),
        best: str(r.data.best), note: str(r.data.note)
      };
      job.namesState = 'done';
    } catch (e) {
      job.namesState = 'failed';
      job.namesErr = e.message;
    }
    const box = $('nc-' + job.key);
    if (box) box.innerHTML = nameCheckInner(job);
  }

  async function runQuick(job) {
    setStep(job, 'Sketching five ' + COLLECTIONS[job.key].label, STEP_MSGS.quick);
    const body = { model: MODEL, max_tokens: TOKENS.quick, messages: [{ role: 'user', content: quickPrompt(job) }] };
    const good = d => list(d.sketches).length > 0;
    let res;
    try { res = await askJSON(body, good); }
    catch (e1) { res = await askJSON(e1.timeout ? Object.assign({}, body, { model: FALLBACK_MODEL }) : body, good); }
    clearInterval(job.timer);
    job.sketches = list(res.data.sketches).map(s => ({
      name: str(pick(s, ['name'])), luck_for: str(pick(s, ['luck_for', 'luck'])), quick: str(pick(s, ['quick', 'one_liner'])),
      hook: str(pick(s, ['hook', 'flaw', 'perspective'])), look: str(pick(s, ['look', 'silhouette'])), line: str(pick(s, ['line', 'ritual', 'thought']))
    })).filter(s => s.name);
    rememberNames(job.sketches.map(s => s.name));
    job.status = 'done';
    job.el.innerHTML = sketchesHTML(job);
    job.el.querySelectorAll('.dev-btn').forEach((btn, i) => {
      btn.addEventListener('click', () => developSketch(job.key, job.sketches[i]));   // closure, not data-attributes
    });
  }

  function developSketch(key, s) {
    setMode('full');
    setOn('misfits', key === 'misfits');
    setOn('persp', key === 'persp');
    const box = $(key === 'misfits' ? 'ideaMisfits' : 'ideaPersp');
    box.value = `Develop this sketch: ${s.name} — ${s.luck_for}. ${s.quick} ${s.hook ? 'Hook: ' + s.hook + '.' : ''} ${s.look ? 'Look: ' + s.look + '.' : ''} Keep the name ${s.name}.`.replace(/\s+/g, ' ').trim();
    window.scrollTo({ top: 0, behavior: 'smooth' });
    setTimeout(generate, 350);
  }

  /* ════════════════════════════════════════════════════
     RENDER
     ════════════════════════════════════════════════════ */
  function esc(s) { return String(s == null ? '' : s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;'); }
  function safeUrl(u) { return /^https?:\/\//i.test(u || '') ? esc(u) : ''; }
  function validHex(h) { h = String(h || '').trim(); if (/^#[0-9a-f]{3}$/i.test(h)) h = '#' + h[1] + h[1] + h[2] + h[2] + h[3] + h[3]; return /^#[0-9a-f]{6}$/i.test(h) ? h : ''; }
  const fld = (k, v, wide) => v ? `<div class="fld${wide ? ' wide' : ''}"><div class="fld-k">${esc(k)}</div><div class="fld-v">${esc(v)}</div></div>` : '';
  const zap = (label, v, big) => v ? `<div class="out-zap${big ? ' big' : ''}"><div class="zap-label">${esc(label)}</div>${esc(v)}</div>` : '';

  function charmHTML(job) {
    const c = job.charm, persp = job.key === 'persp', C = COLLECTIONS[job.key], d = c.draw;
    const palette = d.palette.length ? `<div class="fld wide"><div class="fld-k">Palette</div><div class="palette">${d.palette.map(p => {
      const hx = validHex(p.hex);
      return `<div class="sw"><div class="sw-chip" style="background:${hx || 'transparent'}"></div><div><div class="sw-name">${esc(p.name || 'color')}</div><div class="sw-hex">${esc(hx || p.hex || '')}</div>${p.where ? `<div class="sw-where">${esc(p.where)}</div>` : ''}</div></div>`;
    }).join('')}</div></div>` : '';
    const poses = d.poses.length ? `<div class="fld wide"><div class="fld-k">Pose &amp; scene ideas</div><div class="fld-v"><ul>${d.poses.map(p => `<li>${esc(p)}</li>`).join('')}</ul></div></div>` : '';

    const headline = persp
      ? zap('Lucky thought', c.lucky_thought, true) + zap('Lucky ritual', c.lucky_ritual)
      : zap('Lucky ritual', c.lucky_ritual, true) + zap('Lucky thought', c.lucky_thought);

    const roots = c.real_roots.map(r => `<div class="roots-item"><div class="roots-fact">${esc(r.fact)}${r.src ? '<span class="badge b-ok">sourced</span>' : '<span class="badge b-mute">verify</span>'}</div>${r.inspires ? `<div class="roots-insp">→ ${esc(r.inspires)}</div>` : ''}${r.src ? `<a class="src-link" href="${safeUrl(r.src)}" target="_blank" rel="noopener">${esc(r.src)}</a>` : ''}</div>`).join('');
    const R = job.research;
    const extra = R ? [
      ...R.traditions.map(t => `<div class="roots-item"><div class="roots-fact">${esc(t.tradition)}<span class="badge b-warn">luck tradition</span></div><a class="src-link" href="${safeUrl(t.url)}" target="_blank" rel="noopener">${esc(t.source || t.url)}</a></div>`),
      ...R.place.map(p => `<div class="roots-item"><div class="roots-fact">${esc(p.detail)}<span class="badge b-warn">local detail</span></div><a class="src-link" href="${safeUrl(p.url)}" target="_blank" rel="noopener">${esc(p.source || p.url)}</a></div>`)
    ].join('') : '';
    const crowded = R && R.crowded.length ? fld('Already out there — steer clear of', R.crowded.map(x => x.name + (x.what ? ' (' + x.what + ')' : '')).join(' · '), true) : '';
    const second = c.second_look.length ? `<div class="fld wide" style="margin-top:12px"><div class="fld-k">Worth a second look</div><div class="fld-v"><ul>${c.second_look.map(s => `<li>${esc(s)}</li>`).join('')}</ul></div></div>` : '';

    return `<section class="charm-sheet ${C.cls}" id="sheet-${job.key}">
      <div class="charm-hero">
        <div class="out-pill pill-accent">${C.emoji} ${esc(C.one)}</div>
        <div class="charm-name">${esc(c.name)}</div>
        ${c.pronunciation ? `<div class="charm-pron">say it: ${esc(c.pronunciation)}</div>` : ''}
        ${c.luck_for ? `<div class="charm-luck">${esc(c.luck_for)}</div>` : ''}
        ${c.quick ? `<div class="charm-quick">${esc(c.quick)}</div>` : ''}
        ${c.motto ? `<div class="charm-motto">“${esc(c.motto)}”</div>` : ''}
        <div class="charm-seed">${job.idea ? 'From your idea: ' + esc(job.idea) : 'Surprise seed: ' + esc(job.seed)}${job.note ? ' · ' + esc(job.note) : ''}</div>
      </div>

      <div class="out-card">
        <div class="out-pill pill-yellow">What It Does</div>
        <div class="out-title">The Full Story</div>
        <div class="out-sub">// ${esc(c.carry_when || 'what it does and why it works')}</div>
        <div class="out-body">${c.what_it_does.map(p => `<p>${esc(p)}</p>`).join('')}</div>
        ${persp ? zap('What it helps you see', c.perspective) + zap('The overlooked thing', c.overlooked)
                : zap('The flaw', c.flaw) + zap('Why the flaw is the superpower', c.superpower)}
        ${headline}
      </div>

      <div class="out-card">
        <div class="out-pill pill-pink">The Folklore</div>
        <div class="out-title">Where It Came From</div>
        <div class="out-sub">// origin, habitat, and its strange little habit</div>
        <div class="fld-grid">
          ${fld('Origin', c.origin, true)}
          ${fld('Habitat', c.habitat)}
          ${fld('Peculiar behavior', c.behavior)}
        </div>
      </div>

      <div class="out-card">
        <div class="out-pill pill-teal">Drawing Brief</div>
        <div class="out-title">What You Draw</div>
        <div class="out-sub">// for the drawing table · MVANNP</div>
        <div class="fld-grid">
          ${fld('Silhouette', d.silhouette, true)}
          ${fld('Deliberate imperfection', d.imperfection)}
          ${fld('Symbolic mark', d.symbol)}
          ${fld('Body', d.body)}
          ${fld('Face & expression', d.face)}
          ${fld('Scale', d.scale)}
          ${fld('Sticker test', d.sticker_test)}
          ${palette}
          ${fld('Reads without words', d.wordless, true)}
          ${poses}
          ${fld('Avoid', d.avoid, true)}
        </div>
      </div>

      <div class="out-card">
        <div class="out-pill pill-orange">Make It a Collection</div>
        <div class="out-title">Cards, Pins &amp; Siblings</div>
        <div class="out-sub">// ideas to carry it off the page</div>
        ${zap('Lucky postcard · card back', c.card_back)}
        <div class="fld-grid" style="margin-top:14px">
          ${c.products.length ? `<div class="fld wide"><div class="fld-k">Product ideas</div><div class="fld-v"><ul>${c.products.map(p => `<li>${esc(p)}</li>`).join('')}</ul></div></div>` : ''}
          ${fld('Family DNA', c.family_dna, true)}
          ${c.siblings.length ? `<div class="fld wide"><div class="fld-k">Siblings to draw next</div><div class="fld-v"><ul>${c.siblings.map(s => `<li><b>${esc(s.name)}</b>${s.luck ? ' — ' + esc(s.luck) : ''}</li>`).join('')}</ul></div></div>` : ''}
          ${c.alt_names.length ? `<div class="fld wide"><div class="fld-k">Other names it could go by</div><div class="tag-row">${c.alt_names.map(n => `<span class="tag">${esc(n)}</span>`).join('')}</div></div>` : ''}
        </div>
      </div>

      <div class="out-card">
        <div class="out-pill pill-lime">Real Roots &amp; Name Check</div>
        <div class="out-title">What It's Built On</div>
        <div class="web-status">${esc(job.webNote)}</div>
        ${roots}${extra}
        ${crowded ? `<div class="fld-grid" style="margin-top:12px">${crowded}</div>` : ''}
        ${second}
        <div class="fld wide" style="margin-top:16px"><div class="fld-k">Name check</div><div id="nc-${job.key}">${nameCheckInner(job)}</div></div>
      </div>
    </section>`;
  }

  function nameCheckInner(job) {
    if (job.namesState === 'off') return '<div class="nc-found">Web check was off — search the name yourself before you publish.</div>';
    if (job.namesState === 'checking') return '<div class="nc-wait">Checking whether the name is already out there…</div>';
    if (job.namesState === 'failed') return `<div class="nc-found">The name check didn't finish (${esc(job.namesErr || '')}). Search “${esc(job.charm.name)} character” yourself before you publish.</div>`;
    const N = job.names; if (!N) return '';
    const badge = s => /taken/.test(s) ? '<span class="badge b-bad">taken</span>' : (/similar/.test(s) ? '<span class="badge b-warn">similar</span>' : '<span class="badge b-ok">clear</span>');
    return N.results.map(x => `<div class="nc-row"><div class="nc-name">${esc(x.name)} ${badge(x.status)}</div><div class="nc-found">${esc(x.found || 'Nothing notable found.')}${x.url ? `<br><a class="src-link" href="${safeUrl(x.url)}" target="_blank" rel="noopener">${esc(x.url)}</a>` : ''}</div></div>`).join('') +
      `<div class="nc-found" style="margin-top:8px">${N.best ? 'Strongest clear name: <b>' + esc(N.best) + '</b>. ' : ''}${esc(N.note)} <i>Quick screen, not a trademark search.</i></div>`;
  }

  function sketchesHTML(job) {
    const C = COLLECTIONS[job.key];
    return `<section class="charm-sheet ${C.cls}" id="sheet-${job.key}">
      <div class="sketch-head">${C.emoji} Five ${esc(C.label)} to choose from</div>
      <div class="sketch-grid">${job.sketches.map(s => `<div class="sketch">
        <div class="sk-name">${esc(s.name)}</div>
        <div class="sk-luck">${esc(s.luck_for)}</div>
        <div class="sk-quick">${esc(s.quick)}</div>
        ${s.hook ? `<div class="sk-line"><b>${job.key === 'persp' ? 'Helps you see' : 'Flaw → superpower'}</b>${esc(s.hook)}</div>` : ''}
        ${s.look ? `<div class="sk-line"><b>Look</b>${esc(s.look)}</div>` : ''}
        ${s.line ? `<div class="sk-line"><b>${job.key === 'persp' ? 'Lucky thought' : 'Lucky ritual'}</b>${esc(s.line)}</div>` : ''}
        <button class="dev-btn" type="button">Develop this one →</button>
      </div>`).join('')}</div>
    </section>`;
  }

  function wireSheet(job) { /* reserved for per-sheet controls */ }

  function renderJump() {
    const done = state.jobs.filter(j => j.charm || j.sketches);
    if (state.jobs.length < 2 || !done.length) { $('jumpRow').innerHTML = ''; return; }
    $('jumpRow').innerHTML = 'Jump to: ' + state.jobs.map(j => `<a href="#job-${j.key}">${esc(j.charm ? j.charm.name : COLLECTIONS[j.key].label)}</a>`).join(' · ');
  }

  /* ════════════════════════════════════════════════════
     TEXT EXPORT (Copy + .txt)
     ════════════════════════════════════════════════════ */
  function charmText(job) {
    const c = job.charm, d = c.draw, persp = job.key === 'persp', L = [];
    const add = (k, v) => { if (v) L.push(k ? k.toUpperCase() + ': ' + v : v); };
    L.push('==============================');
    L.push(c.name.toUpperCase() + (c.pronunciation ? '  (' + c.pronunciation + ')' : ''));
    L.push(COLLECTIONS[job.key].one + (c.luck_for ? ' · ' + c.luck_for : ''));
    L.push('==============================');
    add('', c.quick); add('Motto', c.motto); L.push('');
    L.push('WHAT IT DOES'); c.what_it_does.forEach(p => L.push(p)); L.push('');
    if (persp) { add('What it helps you see', c.perspective); add('The overlooked thing', c.overlooked); }
    else { add('The flaw', c.flaw); add('Why the flaw is the superpower', c.superpower); }
    add('Lucky ritual', c.lucky_ritual); add('Lucky thought', c.lucky_thought); add('Carry it when', c.carry_when); L.push('');
    L.push('FOLKLORE'); add('Origin', c.origin); add('Habitat', c.habitat); add('Peculiar behavior', c.behavior); L.push('');
    L.push('DRAWING BRIEF'); add('Silhouette', d.silhouette); add('Deliberate imperfection', d.imperfection); add('Symbolic mark', d.symbol);
    add('Body', d.body); add('Face & expression', d.face); add('Scale', d.scale); add('Sticker test', d.sticker_test);
    if (d.palette.length) L.push('PALETTE: ' + d.palette.map(p => (p.name || 'color') + ' ' + (validHex(p.hex) || p.hex || '') + (p.where ? ' (' + p.where + ')' : '')).join('; '));
    add('Reads without words', d.wordless);
    if (d.poses.length) { L.push('POSE & SCENE IDEAS:'); d.poses.forEach(p => L.push(' - ' + p)); }
    add('Avoid', d.avoid); L.push('');
    L.push('MAKE IT A COLLECTION'); add('Card back', c.card_back);
    if (c.products.length) { L.push('PRODUCT IDEAS:'); c.products.forEach(p => L.push(' - ' + p)); }
    add('Family DNA', c.family_dna);
    if (c.siblings.length) { L.push('SIBLINGS:'); c.siblings.forEach(s => L.push(' - ' + s.name + (s.luck ? ' — ' + s.luck : ''))); }
    if (c.alt_names.length) add('Other names', c.alt_names.join(', '));
    L.push('');
    L.push('REAL ROOTS  [' + job.webNote + ']');
    c.real_roots.forEach(r => L.push(' - ' + r.fact + (r.inspires ? ' → ' + r.inspires : '') + (r.src ? ' (' + r.src + ')' : ' (verify)')));
    if (job.research) {
      job.research.traditions.forEach(t => L.push(' - Luck tradition: ' + t.tradition + ' (' + t.url + ')'));
      job.research.place.forEach(p => L.push(' - Local detail: ' + p.detail + ' (' + p.url + ')'));
      if (job.research.crowded.length) L.push('ALREADY OUT THERE: ' + job.research.crowded.map(x => x.name).join(', '));
    }
    if (c.second_look.length) { L.push('WORTH A SECOND LOOK:'); c.second_look.forEach(s => L.push(' - ' + s)); }
    if (job.namesState === 'done' && job.names) {
      L.push('NAME CHECK (quick screen, not a trademark search):');
      job.names.results.forEach(x => L.push(' - ' + x.name + ': ' + x.status + (x.found ? ' — ' + x.found : '')));
    }
    return L.join('\n');
  }

  function allText() {
    const parts = state.jobs.filter(j => j.charm).map(charmText);
    return 'MASCOT CHARM GENERATOR · Quirky Flash Chronicles · MVANNP\n' + new Date().toLocaleDateString() + '\n\n' + parts.join('\n\n\n');
  }

  function copyText() {
    const t = allText();
    const done = () => { const c = $('copyConfirm'); c.classList.add('show'); setTimeout(() => c.classList.remove('show'), 1800); };
    if (navigator.clipboard && navigator.clipboard.writeText) navigator.clipboard.writeText(t).then(done, () => legacyCopy(t, done));
    else legacyCopy(t, done);
  }
  function legacyCopy(t, done) {
    const ta = document.createElement('textarea'); ta.value = t; ta.style.position = 'fixed'; ta.style.opacity = '0';
    document.body.appendChild(ta); ta.select(); try { document.execCommand('copy'); done(); } catch (e) {} ta.remove();
  }

  function fileBase() {
    const names = state.jobs.filter(j => j.charm).map(j => pdfSlug(j.charm.name));
    return 'charm-' + (names.join('-') || 'mascot') + '-' + pdfDateStamp();
  }

  function downloadTxt() {
    const blob = new Blob([allText()], { type: 'text/plain;charset=utf-8' });
    const a = document.createElement('a'); a.href = URL.createObjectURL(blob); a.download = fileBase() + '.txt';
    document.body.appendChild(a); a.click(); setTimeout(() => { URL.revokeObjectURL(a.href); a.remove(); }, 500);
  }

  /* ════════════════════════════════════════════════════
     PDF EXPORT — native-text PDF, same engine as Seeds & Worms:
     1. Draws REAL text + shapes with jsPDF. No screenshots: crisp, a few KB.
     2. pdfSafe() swaps curly quotes / dashes / arrows and drops emoji
        (standard PDF fonts only draw basic Latin letters).
     3. Reads the normalized charm, so a renamed field can't blank the PDF.
     4. If jsPDF didn't load (offline / CDN hiccup), falls back to Print.
     ════════════════════════════════════════════════════ */
  function pdfSafe(s) {
    if (s === null || s === undefined) return '';
    if (typeof s === 'object') s = Array.isArray(s) ? s.join(', ') : JSON.stringify(s);
    return String(s)
      .replace(/\r/g, '')
      .replace(/[‘’‚′]/g, "'")
      .replace(/[“”„″]/g, '"')
      .replace(/—/g, '--')
      .replace(/[–−‐‑]/g, '-')
      .replace(/…/g, '...')
      .replace(/[•●▪]/g, '-')
      .replace(/[→➡➔]/g, '->')
      .replace(/←/g, '<-')
      .replace(/ /g, ' ')
      .replace(/[\x80-\x9F]/g, '')
      .replace(/[^\x00-\xFF]/g, '')
      .replace(/[ \t]{2,}/g, ' ')
      .replace(/ +([.,!?;])/g, '$1')
      .trim();
  }
  function pdfSlug(s) { return pdfSafe(s).toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '').slice(0, 30) || 'charm'; }
  function pdfDateStamp() { const n = new Date(), p = x => String(x).padStart(2, '0'); return `${n.getFullYear()}-${p(n.getMonth() + 1)}-${p(n.getDate())}`; }
  function pdfPrettyDate() { try { return new Date().toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' }); } catch (e) { return pdfDateStamp(); } }
  function hexRgb(h) { h = validHex(h); return h ? [parseInt(h.slice(1, 3), 16), parseInt(h.slice(3, 5), 16), parseInt(h.slice(5, 7), 16)] : null; }

  const PDF_THEMES = {
    dark: {
      bg: [26, 15, 51], panel: [42, 26, 74], text: [255, 251, 232], body: [232, 226, 244], muted: [165, 155, 190],
      rule: [70, 52, 110], yellow: [255, 229, 53], lime: [200, 240, 0], pink: [240, 62, 140],
      teal: [44, 191, 176], orange: [255, 124, 42], purple: [167, 139, 250], box: [70, 52, 110]
    },
    light: {
      bg: [255, 252, 242], panel: [244, 238, 222], text: [26, 10, 46], body: [48, 38, 64], muted: [120, 110, 132],
      rule: [214, 204, 186], yellow: [176, 120, 0], lime: [74, 110, 0], pink: [196, 0, 110],
      teal: [14, 120, 110], orange: [196, 82, 10], purple: [91, 33, 182], box: [190, 180, 160]
    }
  };

  function pdfBegin(C) {
    const { jsPDF } = window.jspdf;
    const P = new jsPDF({ unit: 'pt', format: 'letter', compress: true });
    const PW = P.internal.pageSize.getWidth(), PH = P.internal.pageSize.getHeight();
    const M = 50, CW = PW - 2 * M, BOTTOM = PH - 56;
    const K = { P, PW, PH, M, CW, C, y: M, BOTTOM };
    const paint = () => { P.setFillColor(C.bg[0], C.bg[1], C.bg[2]); P.rect(0, 0, PW, PH, 'F'); };
    paint();
    K.newPage = () => { P.addPage(); paint(); K.y = M; };
    K.need = h => { if (K.y + h > BOTTOM) { K.newPage(); return true; } return false; };
    K.font = (style, size, rgb) => {
      const fam = (style === 'mono' || style === 'monobold') ? 'courier' : 'helvetica';
      const wt = (style === 'bold' || style === 'monobold') ? 'bold' : (style === 'italic' ? 'italic' : 'normal');
      P.setFont(fam, wt); P.setFontSize(size); P.setTextColor(rgb[0], rgb[1], rgb[2]);
    };
    K.wrap = (s, w, style, size) => { K.font(style, size, C.text); return P.splitTextToSize(pdfSafe(s), w); };
    K.para = (s, opts) => {
      const o = Object.assign({ x: M, w: CW, size: 11, style: 'normal', rgb: C.body, lh: null }, opts || {});
      const t = pdfSafe(s); if (!t) return;
      const step = o.lh || o.size * 1.42;
      for (const ln of K.wrap(t, o.w, o.style, o.size)) { K.need(step); K.font(o.style, o.size, o.rgb); P.text(ln, o.x, K.y + o.size * 0.82); K.y += step; }
    };
    K.rule = (rgb, weight) => { P.setDrawColor(rgb[0], rgb[1], rgb[2]); P.setLineWidth(weight || 0.7); P.line(M, K.y, M + CW, K.y); };
    K.sectionHead = (name, rgb, sub) => {
      K.y += 14; K.need(80);   // keep a heading with at least its first lines (no orphaned headings)
      const label = pdfSafe(name).toUpperCase();
      K.font('bold', 12, rgb); P.text(label, M, K.y + 10);
      if (sub) { const nw = P.getTextWidth(label); K.font('mono', 8, C.muted); P.text(pdfSafe(sub), M + nw + 10, K.y + 9.5); }
      K.y += 17; K.rule(C.rule, 0.6); K.y += 11;
    };
    K.labeled = (label, body, rgb) => {
      const t = pdfSafe(body); if (!t) return;
      K.y += 5; K.need(32);
      K.font('monobold', 8.5, rgb); P.text(pdfSafe(label).toUpperCase(), M, K.y + 7); K.y += 13;
      K.para(t, { size: 10.5, lh: 14.5 }); K.y += 2;
    };
    K.bullets = (label, items, rgb) => {
      items = (items || []).map(pdfSafe).filter(Boolean); if (!items.length) return;
      K.y += 5; K.need(32);
      K.font('monobold', 8.5, rgb); P.text(pdfSafe(label).toUpperCase(), M, K.y + 7); K.y += 13;
      items.forEach(it => {
        const lines = K.wrap(it, CW - 14, 'normal', 10.5);
        lines.forEach((ln, i) => { K.need(14.5); K.font('normal', 10.5, C.body); if (i === 0) P.text('-', M + 2, K.y + 8.6); P.text(ln, M + 14, K.y + 8.6); K.y += 14.5; });
      });
      K.y += 2;
    };
    K.box = (label, body, rgb, opts) => {
      const o = Object.assign({ size: 12, style: 'normal', rgb: C.text, fill: C.panel }, opts || {});
      const t = pdfSafe(body); if (!t) return;
      const pad = 14, lh = o.size * 1.4;
      const lines = K.wrap(t, CW - 2 * pad - 4, o.style, o.size);
      const boxH = pad + 12 + lines.length * lh + pad - 2;
      K.y += 8;
      if (boxH > (BOTTOM - M)) { K.labeled(label, t, rgb); return; }
      K.need(boxH);
      P.setFillColor(o.fill[0], o.fill[1], o.fill[2]); P.rect(M, K.y, CW, boxH, 'F');
      P.setFillColor(rgb[0], rgb[1], rgb[2]); P.rect(M, K.y, 3.5, boxH, 'F');
      let by = K.y + pad + 6;
      K.font('monobold', 8.5, rgb); P.text(pdfSafe(label).toUpperCase(), M + pad + 4, by); by += 10;
      K.font(o.style, o.size, o.rgb);
      for (const ln of lines) { P.text(ln, M + pad + 4, by + o.size * 0.82); by += lh; }
      K.y += boxH + 4;
    };
    K.footer = left => {
      const total = P.getNumberOfPages();
      for (let p = 1; p <= total; p++) {
        P.setPage(p); K.font('mono', 7, C.muted);
        P.text(pdfSafe(left), M, PH - 28);
        P.text(`p ${p} / ${total}`, PW - M, PH - 28, { align: 'right' });
      }
    };
    return K;
  }

  function pdfCharm(K, job, first) {
    const P = K.P, M = K.M, CW = K.CW, C = K.C, c = job.charm, d = c.draw, persp = job.key === 'persp';
    const A = persp ? C.teal : C.orange;
    if (!first) K.newPage();
    K.y = M + 4;
    K.font('mono', 8.5, C.teal); P.text('QUIRKY FLASH CHRONICLES  ·  MASCOT CHARM  ·  ' + pdfSafe(COLLECTIONS[job.key].label).toUpperCase(), M, K.y + 7); K.y += 28;
    K.para(c.name.toUpperCase(), { size: 34, style: 'bold', rgb: C.yellow, lh: 38 });
    if (c.pronunciation) { K.font('mono', 9, C.muted); P.text('say it: ' + pdfSafe(c.pronunciation), M, K.y + 6); K.y += 16; }
    if (c.luck_for) { K.para(c.luck_for.toUpperCase(), { size: 12.5, style: 'bold', rgb: A, lh: 17 }); }
    K.y += 6; K.rule(C.pink, 1.2); K.y += 14;
    K.para(c.quick, { size: 15, style: 'bold', rgb: C.text, lh: 20 });
    if (c.motto) { K.y += 2; K.para('"' + c.motto + '"', { size: 11, style: 'italic', rgb: C.lime, lh: 15 }); }
    K.font('mono', 8, C.muted); K.need(14); P.text('Generated ' + pdfSafe(pdfPrettyDate()) + '  ·  ' + (job.idea ? 'from your idea: ' + pdfSafe(job.idea).slice(0, 70) : 'surprise seed: ' + pdfSafe(job.seed)), M, K.y + 9); K.y += 16;

    K.box(persp ? 'Lucky thought' : 'Lucky ritual', persp ? c.lucky_thought : c.lucky_ritual, C.yellow, { size: 15, style: 'bold' });

    K.sectionHead('What it does', C.yellow, c.carry_when ? '' : 'the full story');
    c.what_it_does.forEach(p => { K.para(p, { size: 11, lh: 16 }); K.y += 5; });
    if (persp) { K.labeled('What it helps you see', c.perspective, A); K.labeled('The overlooked thing', c.overlooked, A); }
    else { K.labeled('The flaw', c.flaw, A); K.labeled('Why the flaw is the superpower', c.superpower, A); }
    K.labeled(persp ? 'Lucky ritual' : 'Lucky thought', persp ? c.lucky_ritual : c.lucky_thought, C.pink);
    K.labeled('Carry it when', c.carry_when, C.pink);

    K.sectionHead('The folklore', C.pink, 'origin, habitat, habit');
    K.labeled('Origin', c.origin, C.pink); K.labeled('Habitat', c.habitat, C.pink); K.labeled('Peculiar behavior', c.behavior, C.pink);

    K.sectionHead('Drawing brief', C.teal, 'what you draw');
    K.labeled('Silhouette', d.silhouette, C.teal); K.labeled('Deliberate imperfection', d.imperfection, C.teal);
    K.labeled('Symbolic mark', d.symbol, C.teal); K.labeled('Body', d.body, C.teal); K.labeled('Face & expression', d.face, C.teal);
    K.labeled('Scale', d.scale, C.teal); K.labeled('Sticker test', d.sticker_test, C.teal);
    if (d.palette.length) {
      K.y += 6; K.need(40);
      K.font('monobold', 8.5, C.teal); P.text('PALETTE', M, K.y + 7); K.y += 14;
      d.palette.forEach(p => {
        const rgb = hexRgb(p.hex);
        const lines = K.wrap((p.name || 'color') + '  ' + (validHex(p.hex) || p.hex || '') + (p.where ? '  --  ' + p.where : ''), CW - 40, 'normal', 10.5);
        const h = Math.max(26, lines.length * 14.5 + 6);
        K.need(h);
        if (rgb) { P.setFillColor(rgb[0], rgb[1], rgb[2]); P.setDrawColor(C.box[0], C.box[1], C.box[2]); P.setLineWidth(0.8); P.roundedRect(M, K.y, 26, 20, 3, 3, 'FD'); }
        K.font('normal', 10.5, C.body); lines.forEach((ln, i) => P.text(ln, M + 36, K.y + 13 + i * 14.5));
        K.y += h;
      });
    }
    K.labeled('Reads without words', d.wordless, C.teal);
    K.bullets('Pose & scene ideas', d.poses, C.teal);
    K.labeled('Avoid', d.avoid, C.pink);

    K.sectionHead('Make it a collection', C.orange, 'cards, pins, siblings');
    K.box('Lucky postcard  ·  card back', c.card_back, C.orange, { size: 12 });
    K.bullets('Product ideas', c.products, C.orange);
    K.labeled('Family DNA', c.family_dna, C.orange);
    K.bullets('Siblings to draw next', c.siblings.map(s => s.name + (s.luck ? ' -- ' + s.luck : '')), C.orange);
    if (c.alt_names.length) K.labeled('Other names', c.alt_names.join('  ·  '), C.orange);

    K.sectionHead('Real roots & name check', C.lime, pdfSafe(job.webNote).slice(0, 70));
    K.bullets('Built on', c.real_roots.map(r => r.fact + (r.inspires ? ' -> ' + r.inspires : '') + (r.src ? '  [' + r.src + ']' : '  [verify]')), C.lime);
    if (job.research) {
      K.bullets('Luck traditions', job.research.traditions.map(t => t.tradition + '  [' + t.url + ']'), C.lime);
      K.bullets('Local details', job.research.place.map(p => p.detail + '  [' + p.url + ']'), C.lime);
      if (job.research.crowded.length) K.labeled('Already out there -- steer clear of', job.research.crowded.map(x => x.name).join(', '), C.lime);
    }
    K.bullets('Worth a second look', c.second_look, C.pink);
    if (job.namesState === 'done' && job.names) {
      K.bullets('Name check (quick screen, not a trademark search)', job.names.results.map(x => x.name + ': ' + x.status.toUpperCase() + (x.found ? ' -- ' + x.found : '')), C.lime);
    } else {
      K.labeled('Name check', job.namesState === 'checking' ? 'Still checking when this PDF was made -- download again in a moment for the result.' : 'Not run -- search the name yourself before you publish.', C.lime);
    }

    // Thumbnail page: three boxes labeled with the pose ideas + a 1-inch sticker test circle.
    K.newPage();
    K.font('mono', 8.5, C.teal); P.text('THUMBNAILS  ·  ' + pdfSafe(c.name).toUpperCase(), M, K.y + 7); K.y += 22;
    const poses = d.poses.length ? d.poses.slice(0, 3) : ['Pose 1', 'Pose 2', 'Pose 3'];
    while (poses.length < 3) poses.push('Pose ' + (poses.length + 1));
    const boxH = 168;
    poses.forEach((p, i) => {
      const lines = K.wrap((i + 1) + '. ' + p, CW, 'normal', 9.5).slice(0, 2);
      K.font('normal', 9.5, C.body); lines.forEach((ln, j) => P.text(ln, M, K.y + 9 + j * 12)); K.y += lines.length * 12 + 4;
      P.setDrawColor(C.box[0], C.box[1], C.box[2]); P.setLineWidth(0.8); P.setLineDashPattern([3, 3], 0);
      P.rect(M, K.y, CW, boxH); P.setLineDashPattern([], 0);
      K.y += boxH + 12;
    });
    const r = 36;   // 72pt = 1 inch diameter
    const cy = K.y + r + 4;
    K.font('monobold', 8, C.muted); P.text('STICKER TEST  ·  1 INCH', M, cy + 3);
    P.setDrawColor(C.box[0], C.box[1], C.box[2]); P.setLineWidth(0.8); P.circle(M + 170, cy, r);
    P.circle(M + 290, cy, r / 2);
    K.font('mono', 7, C.muted); P.text('1/2 inch', M + 290 - 14, cy + r / 2 + 12);
  }

  function buildPDF(jobs, paper) {
    const C = PDF_THEMES[paper] || PDF_THEMES.dark;
    const K = pdfBegin(C);
    jobs.forEach((job, i) => pdfCharm(K, job, i === 0));
    K.footer('MASCOT CHARM GENERATOR  ·  QUIRKY FLASH CHRONICLES  ·  STUDIO BITS OF GRAVITY  ·  MVANNP');
    return K.P;
  }

  function downloadPDF() {
    const jobs = state.jobs.filter(j => j.charm);
    if (!jobs.length) return;
    if (!(window.jspdf && window.jspdf.jsPDF)) { window.print(); return; }
    const btn = $('pdfBtn'), old = btn.textContent;
    btn.disabled = true; btn.textContent = '… building PDF';
    try { buildPDF(jobs, state.paper).save(fileBase() + '.pdf'); }
    catch (e) { const box = $('outError'); box.textContent = 'PDF didn\'t build — tap Download PDF again. (' + e.message + ')'; box.style.display = 'block'; }
    finally { btn.disabled = false; btn.textContent = old; }
  }

  /* ════════════════════════════════════════════════════
     UI WIRING (event listeners via JS, not inline data — the Idiomator copy-button lesson)
     ════════════════════════════════════════════════════ */
  function showError(m) { const b = $('errorBox'); b.textContent = m; b.classList.add('visible'); }
  function hideError() { $('errorBox').classList.remove('visible'); }

  function setOn(key, on) {
    state.on[key] = on;
    $(key === 'misfits' ? 'optMisfits' : 'optPersp').classList.toggle('on', on);
    updateNotes();
  }
  function updateNotes() {
    ['misfits', 'persp'].forEach(k => {
      const note = $(k === 'misfits' ? 'noteMisfits' : 'notePersp');
      const idea = $(k === 'misfits' ? 'ideaMisfits' : 'ideaPersp').value.trim();
      note.textContent = !state.on[k] ? 'Off — tap the title (or type an idea) to include it.' : (idea ? '' : 'Blank = surprise me.');
    });
    const both = state.on.misfits && state.on.persp;
    $('generateBtn').textContent = state.mode === 'quick'
      ? '✎ SKETCH ' + (both ? 'BOTH COLLECTIONS' : 'FIVE IDEAS') + ' ✎'
      : (both ? '🍀 MAKE BOTH CHARMS! 🍀' : '🍀 MAKE THE CHARM! 🍀');
  }
  function setMode(mode) {
    state.mode = mode;
    document.querySelectorAll('#modeRow .pill-btn').forEach(b => b.classList.toggle('active', b.dataset.mode === mode));
    $('modeNote').textContent = mode === 'quick'
      ? 'Five rough concepts per collection, fast — tap “Develop this one” on any you like.'
      : 'One finished concept per collection — name, what it does, folklore, and a full drawing brief.';
    $('webWrap').style.display = mode === 'quick' ? 'none' : '';
    updateNotes();
  }

  document.querySelectorAll('.opt-card').forEach(card => {
    const key = card.dataset.key;
    card.querySelector('.opt-head').addEventListener('click', () => setOn(key, !state.on[key]));
    card.querySelector('.opt-idea').addEventListener('input', e => { if (e.target.value.trim() && !state.on[key]) setOn(key, true); else updateNotes(); });
  });
  $('sameBtn').addEventListener('click', () => {
    const a = $('ideaMisfits'), b = $('ideaPersp');
    const src = a.value.trim() || b.value.trim();
    if (!src) { showError('Type an idea in either box first, then tap “Use the same idea for both.”'); return; }
    hideError(); a.value = src; b.value = src; setOn('misfits', true); setOn('persp', true);
  });
  document.querySelectorAll('#modeRow .pill-btn').forEach(b => b.addEventListener('click', () => setMode(b.dataset.mode)));
  document.querySelectorAll('#forGrid .pill-btn').forEach(b => b.addEventListener('click', () => {
    state.madeFor = b.dataset.for;
    document.querySelectorAll('#forGrid .pill-btn').forEach(x => x.classList.toggle('active', x === b));
  }));
  document.querySelectorAll('#inspoGrid .pill-btn').forEach(b => b.addEventListener('click', () => {
    b.classList.toggle('active');
    state.inspo = Array.from(document.querySelectorAll('#inspoGrid .pill-btn.active')).map(x => x.dataset.inspo);
  }));
  $('webBtn').addEventListener('click', () => {
    state.web = !state.web;
    $('webBtn').classList.toggle('active', state.web);
    $('webBtn').textContent = '🔎 Web check: ' + (state.web ? 'ON' : 'OFF');
    $('webNote').textContent = state.web
      ? 'Grounds each charm in real science & folklore with sources, and screens the name against existing characters. Adds about a minute.'
      : 'Faster. Real roots come from general knowledge (flagged “verify”), and there’s no name check.';
  });
  document.querySelectorAll('#paperToggle button').forEach(b => b.addEventListener('click', () => {
    state.paper = b.dataset.paper;
    document.querySelectorAll('#paperToggle button').forEach(x => x.classList.toggle('active', x === b));
  }));
  $('generateBtn').addEventListener('click', generate);
  $('againBtn').addEventListener('click', () => { window.scrollTo({ top: 0, behavior: 'smooth' }); generate(); });
  $('copyBtn').addEventListener('click', copyText);
  $('txtBtn').addEventListener('click', downloadTxt);
  $('pdfBtn').addEventListener('click', downloadPDF);
  updateNotes();
</script>
</body>
</html>
