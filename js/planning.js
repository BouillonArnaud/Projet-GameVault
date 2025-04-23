document.addEventListener("DOMContentLoaded", function () {
  fetchJeuxNonSortis();
});

function fetchJeuxNonSortis() {
  fetch("php/planning.php")
    .then((response) => response.json())
    .then((data) => {
      const container = document.getElementById("jeux-container");

      if (data.length === 0) {
        container.innerHTML = `
                  <div class="col-12">
                      <div class="no-games">
                          Aucun jeu à venir pour le moment.
                      </div>
                  </div>
              `;
        return;
      }

      data.forEach((jeu) => {
        const col = document.createElement("div");
        col.className = "col-md-4 col-lg-3 mb-4";

        const dateSortie = new Date(jeu.date_sortie);
        const options = { year: "numeric", month: "long", day: "numeric" };
        const dateFormatee = dateSortie.toLocaleDateString("fr-FR", options);

        col.innerHTML = `
                  <div class="card">
                      <img src="${jeu.IMG_jeux}" class="card-img-top" alt="${jeu.nom_jeu}">
                      <div class="card-body">
                          <h5 class="card-title">${jeu.nom_jeu}</h5>
                          <p class="card-text">Plateforme: ${jeu.plateforme}</p>
                          <p class="card-text">Editeur: ${jeu.nom_editeur}</p>
                          <p class="card-text">Édition: ${jeu.edition_jeu}</p>
                          <p class="card-text game-date">Sortie: ${dateFormatee}</p>
                          <a href="${jeu.Lien}" class="game-link" target="_blank">Plus d'infos</a>
                      </div>
                  </div>
              `;

        container.appendChild(col);
      });
    })
    .catch((error) => {
      console.error("Erreur:", error);
      document.getElementById("jeux-container").innerHTML = `
              <div class="col-12">
                  <div class="no-games">
                      Erreur lors du chargement des jeux à venir.
                  </div>
              </div>
          `;
    });
}
