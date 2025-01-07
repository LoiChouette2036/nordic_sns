import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.initializeCanvas();
  }

  initializeCanvas() {
    const canvas = this.element;
    const context = canvas.getContext("2d");
    const stars = [];
    const fps = 50; // Frames per second
    const numStars = 200; // Number of stars

    // Function to set canvas dimensions
    function setCanvasSize() {
      canvas.width = window.innerWidth; // Full width
      canvas.height = window.innerHeight * 0.4; // Sky area height
    }

    // Initialize canvas size on load
    setCanvasSize();

    // Recalculate canvas size on window resize
    window.addEventListener("resize", setCanvasSize);

    // Create stars
    for (let i = 0; i < numStars; i++) {
      const x = Math.random() * canvas.width;
      const y = Math.random() * canvas.height;
      const length = 1 + Math.random() * 2;
      const opacity = Math.random();
      const star = new Star(x, y, length, opacity);
      stars.push(star);
    }

    // Define the Star class
    function Star(x, y, length, opacity) {
      this.x = x;
      this.y = y;
      this.length = length;
      this.opacity = opacity;
      this.factor = 1;
      this.increment = Math.random() * 0.03;
    }

    // Draw stars with color based on their x-coordinate
    Star.prototype.draw = function () {
      context.save();
      context.translate(this.x, this.y);

      if (this.opacity > 1) this.factor = -1;
      else if (this.opacity <= 0) this.factor = 1;

      this.opacity += this.increment * this.factor;

      context.beginPath();
      context.arc(0, 0, this.length, 0, 2 * Math.PI);
      context.closePath();

      // Determine the star's color based on its position
      const canvasWidth = canvas.width;
      let starColor;

      if (this.x < canvasWidth / 3) {
        // Left section: Gold-Dark
        starColor = `rgba(218, 165, 32, ${this.opacity})`; // Goldenrod
      } else if (this.x < (2 * canvasWidth) / 3) {
        // Middle section: Bright Gold
        starColor = `rgba(255, 215, 0, ${this.opacity})`; // Pure Gold
      } else {
        // Right section: Gold-Dark
        starColor = `rgba(218, 165, 32, ${this.opacity})`; // Goldenrod
      }

      context.fillStyle = starColor;
      context.shadowBlur = 10; // Glow intensity
      context.shadowColor = starColor; // Shadow matches the star color
      context.fill();

      context.restore();
    };

    // Animation loop
    function animate() {
      context.clearRect(0, 0, canvas.width, canvas.height); // Clear the canvas

      // Draw each star
      for (let i = 0; i < stars.length; i++) {
        stars[i].draw();
      }

      requestAnimationFrame(animate);
    }

    animate(); // Start the animation
  }
}
