// Modern Queue Dashboard JavaScript - This is a placeholder
// In a real application, this would be compiled
console.log('Modern Queue Dashboard loaded'); 

// Add auto-refresh functionality
document.addEventListener('turbo:load', () => {
  const dashboardElement = document.querySelector('.modern-queue-dashboard');
  
  if (dashboardElement) {
    // Get refresh interval from data attribute (or default to 5000ms)
    const refreshInterval = (parseInt(dashboardElement.dataset.refreshInterval) || 5) * 1000;
    
    console.log(`Setting dashboard refresh interval: ${refreshInterval}ms`);
    
    setInterval(() => {
      Turbo.visit(window.location.href, { action: 'replace' });
    }, refreshInterval);
  }
}); 