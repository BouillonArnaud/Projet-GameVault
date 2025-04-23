document
  .getElementById("form-connexion")
  .addEventListener("submit", async function (e) {
    e.preventDefault();

    const identifiant = document.getElementById("identifiant").value.trim();
    const mot_de_passe = document.getElementById("mot_de_passe").value;

    try {
      const response = await fetch("php/connexion.php", {
        method: "POST",
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: `identifiant=${encodeURIComponent(
          identifiant
        )}&mot_de_passe=${encodeURIComponent(mot_de_passe)}`,
      });

      const data = await response.json();

      if (data.success) {
        // Stocker le rôle dans localStorage pour le frontend
        localStorage.setItem("userRole", data.role);

        showModal("Connexion réussie", "Redirection en cours...", false);
        setTimeout(() => {
          window.location.href = "index.html";
        }, 1500);
      } else {
        showModal("Erreur", data.message, true);
      }
    } catch (error) {
      showModal("Erreur", "Une erreur est survenue", true);
      console.error("Erreur:", error);
    }
  });

function showModal(title, message, isError) {
  const modal = new bootstrap.Modal(document.getElementById("messageModal"));
  const modalTitle = document.getElementById("modalTitle");
  const modalBody = document.getElementById("modalBody");

  modalTitle.textContent = title;
  modalBody.textContent = message;
  modalTitle.className = `modal-title ${
    isError ? "text-danger" : "text-success"
  }`;

  modal.show();
}
