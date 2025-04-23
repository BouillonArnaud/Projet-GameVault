// Récupère le rôle depuis localStorage ou définit 'guest' par défaut
function getCurrentRole() {
  return localStorage.getItem("userRole") || "guest";
}

function isGuest() {
  console.log(getCurrentRole());
  return getCurrentRole() === "guest";
}

function isUser() {
  console.log(getCurrentRole());
  return getCurrentRole() === "standard";
}

function isAdmin() {
  console.log(getCurrentRole());
  return getCurrentRole() === "admin";
}

function setupLogout() {
  const logoutLink = document.getElementById("logout-link");
  if (logoutLink) {
    logoutLink.addEventListener("click", function (e) {
      e.preventDefault();
      logout();
    });
  }
}

// Modifiez la fonction updateNav()
function updateNav() {
  const planningItem = document.getElementById("planning-item");
  const connexionItem = document.getElementById("connexion-item");
  const profilItem = document.getElementById("profil-item");
  const logoutItem = document.getElementById("logout-item");
  const dashBoardItem = document.getElementById("dashboard-item");

  if (!isGuest()) {
    // Utilisateur connecté
    connexionItem.style.display = "none";
    logoutItem.style.display = "block";
    profilItem.style.display = "block";
    planningItem.style.display = "block";

    dashBoardItem.style.display = isAdmin() ? "block" : "none";
  } else {
    // Invité
    connexionItem.style.display = "block";
    logoutItem.style.display = "none";
    profilItem.style.display = "none";
    planningItem.style.display = "block";
    dashBoardItem.style.display = "none";
  }
}

async function logout() {
  fetch("php/logout.php")
    .then((response) => response.json())
    .then((data) => {
      if (data.success) {
        // Nettoyer le localStorage
        localStorage.removeItem("userRole");
        // Recharger la page
        window.location.href = "index.html";
      }
    })
    .catch((error) => {
      console.error("Erreur lors de la déconnexion:", error);
    });
}

// Ajoutez ceci à l'initialisation
document.addEventListener("DOMContentLoaded", function () {
  updateNav();
  setupLogout();
});

// Testez ces valeurs dans la console
console.log("Debug:");
console.log("isGuest:", isGuest());
console.log("Planning item:", document.getElementById("planning-item"));
console.log("Connexion item:", document.getElementById("connexion-item"));
