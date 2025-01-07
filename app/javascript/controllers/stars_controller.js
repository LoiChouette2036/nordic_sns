import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.initializeCanvas();
  }

  initializeCanvas() {
    const canvas = this.element;
    const context = canvas.getContext("2d");
    let stars = []; // Stocke les étoiles
    const numStars = 200; // Nombre d'étoiles
    let glowOpacity = 0.08; // Opacité initiale pour le glow (très subtil)
    let glowDirection = 1; // Direction pour la pulsation (1 = augmente, -1 = diminue)

    // Fonction pour ajuster la taille du canvas
    function setCanvasSize() {
      canvas.width = window.innerWidth; // Largeur totale
      canvas.height = window.innerHeight * 0.4; // Hauteur de la zone du ciel
    }

    setCanvasSize();

    // Fonction pour créer les étoiles
    function createStars() {
      stars = []; // Réinitialise le tableau des étoiles
      for (let i = 0; i < numStars; i++) {
        const x = Math.random() * canvas.width;
        const y = Math.random() * canvas.height;
        const length = 1 + Math.random() * 2;
        const opacity = Math.random();
        const star = new Star(x, y, length, opacity);
        stars.push(star);
      }
    }

    createStars(); // Crée les étoiles initialement

    // Redimensionne le canvas et recrée les étoiles lorsque la fenêtre change de taille
    window.addEventListener("resize", () => {
      setCanvasSize(); // Ajuste la taille du canvas
      createStars(); // Recrée les étoiles pour la nouvelle taille
    });

    // Classe pour les étoiles
    function Star(x, y, length, opacity) {
      this.x = x;
      this.y = y;
      this.length = length;
      this.opacity = opacity;
      this.factor = 1;
      this.increment = Math.random() * 0.03;
    }

    // Méthode pour dessiner une étoile
    Star.prototype.draw = function () {
      context.save();
      context.translate(this.x, this.y);

      if (this.opacity > 1) this.factor = -1;
      else if (this.opacity <= 0) this.factor = 1;

      this.opacity += this.increment * this.factor;

      context.beginPath();
      context.arc(0, 0, this.length, 0, 2 * Math.PI);
      context.closePath();

      const canvasWidth = canvas.width;
      let starColor;

      if (this.x < canvasWidth / 3) {
        starColor = `rgba(218, 165, 32, ${this.opacity})`; // Gold-Dark
      } else if (this.x < (2 * canvasWidth) / 3) {
        starColor = `rgba(255, 215, 0, ${this.opacity})`; // Bright Gold
      } else {
        starColor = `rgba(218, 165, 32, ${this.opacity})`; // Gold-Dark
      }

      context.fillStyle = starColor;
      context.shadowBlur = 10;
      context.shadowColor = starColor;
      context.fill();

      context.restore();
    };

    // Dessiner l'effet de glow
    function drawGlow() {
      const treeX = canvas.width / 2; // Centre horizontal du canvas
      const treeY = canvas.height * 0.5; // Centre vertical (légèrement plus bas)
      const glowRadius = 150; // Taille du glow

      // Ajuste l'opacité pour l'effet de pulsation
      if (glowOpacity >= 0.1) glowDirection = -1; // Diminue l'opacité
      else if (glowOpacity <= 0.05) glowDirection = 1; // Augmente l'opacité
      glowOpacity += glowDirection * 0.002; // Variation lente

      // Dégradé radial pour le glow
      const gradient = context.createRadialGradient(
        treeX,
        treeY,
        glowRadius * 0.1, // Rayon intérieur (effet doux)
        treeX,
        treeY,
        glowRadius // Rayon extérieur (effet diffus)
      );
      gradient.addColorStop(0, `rgba(255, 215, 0, ${glowOpacity * 2})`); // Doré brillant au centre
      gradient.addColorStop(0.5, `rgba(255, 223, 0, ${glowOpacity})`); // Doré doux
      gradient.addColorStop(1, "rgba(255, 215, 0, 0)"); // Transparent aux bords

      context.save();
      context.beginPath();
      context.arc(treeX, treeY, glowRadius, 0, 2 * Math.PI); // Cercle pour le glow
      context.closePath();
      context.fillStyle = gradient;
      context.fill();
      context.restore();
    }

    // Boucle d'animation
    function animate() {
      context.clearRect(0, 0, canvas.width, canvas.height); // Efface le canvas

      // Dessine les étoiles
      for (let i = 0; i < stars.length; i++) {
        stars[i].draw();
      }

      // Dessine le glow
      drawGlow();

      requestAnimationFrame(animate); // Boucle d'animation
    }

    animate();
  }
}
