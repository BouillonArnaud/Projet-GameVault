document.addEventListener("DOMContentLoaded", function () {
  const form = document.getElementById("form-inscription");

  form.addEventListener("submit", async function (e) {
    e.preventDefault();
    e.stopPropagation();

    // Réinitialisation des erreurs
    clearErrors();

    // Validation
    const errors = validateForm();
    if (errors.length > 0) {
      showModal("Erreur", errors.join("<br>"), true);
      return;
    }

    // Envoi des données
    try {
      const response = await fetch("php/traitement_inscription.php", {
        method: "POST",
        body: new FormData(form),
        headers: {
          Accept: "application/json",
        },
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.message || "Erreur serveur");
      }

      if (data.success) {
        showModal("Succès", data.message, false);
        form.reset();
      } else {
        highlightErrors(data.errors || {});
        showModal(
          "Erreur",
          data.message || "Erreur lors de l'inscription",
          true
        );
      }
    } catch (error) {
      showModal("Erreur", error.message || "Erreur de connexion", true);
      console.error("Erreur:", error);
    }
  });

  function validateForm() {
    const errors = [];
    const fields = {
      nom_utilisateur: {
        value: form.nom_utilisateur.value.trim(),
        min: 1,
        max: 50,
      },
      email: {
        value: form.email.value.trim(),
        regex: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
      },
      mot_de_passe: {
        value: form.mot_de_passe.value,
        min: 8,
      },
      confirmation_mot_de_passe: {
        value: form.confirmation_mot_de_passe.value,
        match: form.mot_de_passe.value,
      },
      date_naissance: {
        value: form.date_naissance.value,
      },
    };

    // Validation des champs
    if (
      !fields.nom_utilisateur.value ||
      fields.nom_utilisateur.value.length > fields.nom_utilisateur.max
    ) {
      errors.push(
        "Le nom d'utilisateur doit contenir entre 1 et 50 caractères"
      );
      form.nom_utilisateur.classList.add("is-invalid");
    }

    if (!fields.email.value || !fields.email.regex.test(fields.email.value)) {
      errors.push("Veuillez entrer une adresse email valide");
      form.email.classList.add("is-invalid");
    }

    if (
      !fields.mot_de_passe.value ||
      fields.mot_de_passe.value.length < fields.mot_de_passe.min
    ) {
      errors.push("Le mot de passe doit contenir au moins 8 caractères");
      form.mot_de_passe.classList.add("is-invalid");
    }

    if (fields.mot_de_passe.value !== fields.confirmation_mot_de_passe.value) {
      errors.push("Les mots de passe ne correspondent pas");
      form.confirmation_mot_de_passe.classList.add("is-invalid");
    }

    if (!fields.date_naissance.value) {
      errors.push("La date de naissance est obligatoire");
      form.date_naissance.classList.add("is-invalid");
    }

    return errors;
  }

  function clearErrors() {
    form.querySelectorAll(".is-invalid").forEach((el) => {
      el.classList.remove("is-invalid");
    });
  }

  function highlightErrors(errors) {
    Object.entries(errors).forEach(([field, message]) => {
      const input = form[field];
      if (input) {
        input.classList.add("is-invalid");
        const feedback = document.getElementById(`feedback-${field}`);
        if (feedback) feedback.textContent = message;
      }
    });
  }

  function showModal(title, message, isError) {
    const modal = new bootstrap.Modal(document.getElementById("messageModal"));
    document.getElementById("modalTitle").textContent = title;
    document.getElementById("modalBody").innerHTML = message;
    document.getElementById("modalTitle").className = `modal-title ${
      isError ? "text-danger" : "text-success"
    }`;
    modal.show();
  }
});
