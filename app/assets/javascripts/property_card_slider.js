class PropertyCardSlider {
  constructor(containerId, propertyId, images, options = {}) {
    this.container = document.getElementById(containerId);
    this.propertyId = propertyId;
    this.images = images || [];
    this.currentIndex = 0;
    this.isPlaying = true;
    this.interval = null;
    this.slideDelay = options.slideDelay || 2500; // 2.5 seconds default
    
    if (this.images.length > 1) {
      this.init();
    }
  }

  init() {
    this.showImage(0);
    this.startAutoSlide();
    this.setupEventListeners();
  }

  showImage(index) {
    this.images.forEach((image, i) => {
      image.classList.toggle('block', i === index);
      image.classList.toggle('hidden', i !== index);
    });
    
    this.currentIndex = index;
  }

  nextImage() {
    if (this.images.length === 0) return;
    
    const nextIndex = (this.currentIndex + 1) % this.images.length;
    this.showImage(nextIndex);
  }

  startAutoSlide() {
    this.stopAutoSlide();
    this.interval = setInterval(() => {
      if (this.isPlaying) {
        this.nextImage();
      }
    }, this.slideDelay);
  }

  stopAutoSlide() {
    if (this.interval) {
      clearInterval(this.interval);
      this.interval = null;
    }
  }

  setupEventListeners() {
    // Pause on hover to avoid interference with click navigation
    this.container.addEventListener('mouseenter', () => {
      this.stopAutoSlide();
    });

    this.container.addEventListener('mouseleave', () => {
      if (this.isPlaying) {
        this.startAutoSlide();
      }
    });

    // Click to navigate to property page
    this.container.addEventListener('click', () => {
      window.location.href = `/properties/${this.propertyId}`;
    });
  }

  resetAutoSlide() {
    this.stopAutoSlide();
    if (this.isPlaying) {
      this.startAutoSlide();
    }
  }

  // Clean up when needed
  destroy() {
    this.stopAutoSlide();
    this.images = [];
    this.currentIndex = 0;
  }
}

// Initialize all property card sliders when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
  // Find all property cards and initialize sliders
  const propertyCards = document.querySelectorAll('[data-property-slider]');
  
  propertyCards.forEach(card => {
    const propertyId = card.dataset.propertyId;
    const images = card.dataset.images ? JSON.parse(card.dataset.images) : [];
    
    if (images.length > 1) {
      new PropertyCardSlider(`property-${propertyId}-slider`, propertyId, images, {
        slideDelay: 2500 // 2.5 seconds
      });
    }
  });
});
