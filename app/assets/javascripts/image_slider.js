class ImageSlider {
  constructor(containerId, options = {}) {
    this.container = document.getElementById(containerId);
    this.images = this.container?.querySelectorAll('.carousel-image') || [];
    this.currentIndex = 0;
    this.isPlaying = true;
    this.interval = null;
    this.slideDelay = options.slideDelay || 3000; // 3 seconds default
    
    if (this.images.length > 0) {
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
    
    // Update counter
    const counter = document.getElementById('currentImage');
    if (counter) {
      counter.textContent = `${index + 1} of ${this.images.length}`;
    }
    
    this.currentIndex = index;
  }

  nextImage() {
    if (this.images.length === 0) return;
    
    const nextIndex = (this.currentIndex + 1) % this.images.length;
    this.showImage(nextIndex);
  }

  prevImage() {
    if (this.images.length === 0) return;
    
    const prevIndex = (this.currentIndex - 1 + this.images.length) % this.images.length;
    this.showImage(prevIndex);
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

  togglePlayPause() {
    this.isPlaying = !this.isPlaying;
    const button = document.getElementById('pausePlayBtn');
    const icon = document.getElementById('pausePlayIcon');
    const text = document.getElementById('pausePlayText');
    
    if (this.isPlaying) {
      this.startAutoSlide();
      if (icon) icon.textContent = '⏸️';
      if (text) text.textContent = 'Pause';
    } else {
      this.stopAutoSlide();
      if (icon) icon.textContent = '⏸️';
      if (text) text.textContent = 'Play';
    }
  }

  setupEventListeners() {
    // Next/Prev buttons
    const prevBtn = document.getElementById('prevBtn');
    const nextBtn = document.getElementById('nextBtn');
    
    if (prevBtn) {
      prevBtn.addEventListener('click', () => {
        this.prevImage();
        this.resetAutoSlide(); // Reset timer when manually changing
      });
    }
    
    if (nextBtn) {
      nextBtn.addEventListener('click', () => {
        this.nextImage();
        this.resetAutoSlide(); // Reset timer when manually changing
      });
    }

    // Play/Pause button
    const pausePlayBtn = document.getElementById('pausePlayBtn');
    if (pausePlayBtn) {
      pausePlayBtn.addEventListener('click', () => {
        this.togglePlayPause();
      });
    }

    // Auto-pause on hover
    this.container.addEventListener('mouseenter', () => {
      this.stopAutoSlide();
    });

    this.container.addEventListener('mouseleave', () => {
      if (this.isPlaying) {
        this.startAutoSlide();
      }
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

// Initialize slider when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
  // Initialize property show page slider
  const propertySlider = new ImageSlider('imageCarousel', {
    slideDelay: 3000 // 3 seconds
  });
});
