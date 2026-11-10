import { module, test } from 'qunit';
import { AppLayoutState } from 'frontile/layout';

module('Unit | AppLayoutState', function () {
  test('defaults are all false', function (assert) {
    const s = new AppLayoutState();
    assert.false(s.sidebarCollapsed);
    assert.false(s.mobileSidebarOpen);
    assert.false(s.asideOpen);
  });

  test('toggleSidebar flips sidebarCollapsed', function (assert) {
    const s = new AppLayoutState();
    s.toggleSidebar();
    assert.true(s.sidebarCollapsed);
    assert.false(s.mobileSidebarOpen);
    assert.false(s.asideOpen);
    s.toggleSidebar();
    assert.false(s.sidebarCollapsed);
  });

  test('collapseSidebar and expandSidebar are idempotent', function (assert) {
    const s = new AppLayoutState();
    s.collapseSidebar();
    s.collapseSidebar();
    assert.true(s.sidebarCollapsed);
    s.expandSidebar();
    s.expandSidebar();
    assert.false(s.sidebarCollapsed);
    assert.false(s.mobileSidebarOpen);
    assert.false(s.asideOpen);
  });

  test('open and close mobile sidebar', function (assert) {
    const s = new AppLayoutState();
    s.openMobileSidebar();
    s.openMobileSidebar();
    assert.true(s.mobileSidebarOpen);
    assert.false(s.sidebarCollapsed);
    s.closeMobileSidebar();
    s.closeMobileSidebar();
    assert.false(s.mobileSidebarOpen);
    assert.false(s.asideOpen);
  });

  test('toggleAside and closeAside', function (assert) {
    const s = new AppLayoutState();
    s.toggleAside();
    assert.true(s.asideOpen);
    assert.false(s.sidebarCollapsed);
    s.toggleAside();
    assert.false(s.asideOpen);
    s.toggleAside();
    s.closeAside();
    s.closeAside();
    assert.false(s.asideOpen);
    assert.false(s.mobileSidebarOpen);
  });

  test('constructor seeds initial values', function (assert) {
    const s = new AppLayoutState({ sidebarCollapsed: true, asideOpen: true });
    assert.true(s.sidebarCollapsed);
    assert.false(s.mobileSidebarOpen);
    assert.true(s.asideOpen);
  });
});
