/**
 * Georgia Malueg
 * CS 132 Final Project
 * Provides the functionality for the Tinder for Athletes website.
 */

(function () {
    "use strict";
    // to count the current card
    let currCard = 0; 
  
    /** Initializes the event listeners */
    function init() {
        const findUserBtn = qs("#find-user-btn");
        const loginForm = qs("#login-form");
        const signupForm = qs("#signup-form");
        const noBtn = qs("#no-btn");
        const matchBtn = qs("#match-btn");

        // believe this is necessary because I have several html pages
        // don't want to initialize button unless I am on the correct html page
        if (findUserBtn) {
            findUserBtn.addEventListener("click", fetchCards);
        }
        if (loginForm) {
            loginForm.addEventListener("submit", handleLogin);
        }
        if (signupForm) {
            signupForm.addEventListener("submit", handleCreateAccount);
        }
        if (noBtn) {
            noBtn.addEventListener("click", fetchCards);
        }
        if (matchBtn) {
            matchBtn.addEventListener("click", fetchCards);
        }
    }

    /**
     * This function gets the user info from the database find cards with the
     * same sport and home state. I had to hardcode the email because I could
     * not figure out how to get the login email to specify per the logged
     * in user.
     */
    function fetchCards() {
        const email = "gmalueg@gmail.com";
    
        // `http://localhost:8000/user-info?email=${encodeURIComponent(email)}`
        fetch(`/user-info?email=${encodeURIComponent(email)}`)
            .then(checkStatus)
            .then((response) => response.json())
            .then((userData) => {
                const { homeState, sportName } = validateUserData(userData);
                return getCards(homeState, sportName);
            })
            .then(checkStatus)
            .then((response) => response.json())
            .then((data) => displayCard(data))
            .catch((err) => console.error("Error fetching cards:", err));
    }
    
    /**
     * Validates the user info and makes sure necessary fields are there
     * @param {Object} userData - The user data fetched from the API
     * @returns {Object} - An object with home_state and sport_name
     */
    function validateUserData(userData) {
        if (!userData || !userData.home_state || !userData.sport_name) {
            throw new Error("User information is incomplete.");
        }
        return {
            homeState: userData.home_state,
            sportName: userData.sport_name
        };
    }

    /**
     * Fetches cards that match the user's home state and sport name
     * @param {string} homeState - The user's home state
     * @param {string} sportName - The user's chosen sport
     * @returns {Promise} - A promise that resolves to the fetch response
     */
    function getCards(homeState, sportName) {
        const queryURL = `/cards?home_state=${encodeURIComponent(homeState)}&sport_name=${encodeURIComponent(sportName)}`;
        return fetch(queryURL);
    }

    /**
     * Post request to validate the user's login
     * @param {Event} event - submit event
    */
    function handleLogin(event) {
        // necessary to be able to redirect
        event.preventDefault();
        const email = qs("#username").value;
        const password = qs("#pass").value;
        fetch("/login", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ email, password }),
        })
            .then(checkStatus)
            .then(() => (window.location.href = "cards.html")) // redirect if successful
            .catch((err) => alert("Login failed. Please check your credentials."));
    }
  
    /**
     * Allows the user to create an account and sends the data the user inputs
     * into the form to the database.
     * @param {Event} event - the event of the user submitting the form
     */
    function handleCreateAccount(event) {  
        event.preventDefault();
    
        const password = qs("#password").value;
        const confirmPassword = qs("#confirmed-password").value;
        if (password !== confirmPassword) {
            alert("Passwords do not match. Please try again.");
            return;
        }
    
        const formData = {
            first_name: qs("#first_name").value,
            last_name: qs("#last_name").value,
            email: qs("#email").value,
            password: qs("#password").value,
            birthday: qs("#birthday").value,
            home_location: qs("#home-state").value,
            bio: qs("#bio").value,
            sport: qs("#sport-id").value,
            experience_level: qs("#experience-level").value,
            preferred_day: qs("#preferred_day").value,
        };
    
        fetch("/createAccount", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(formData),
        })
            .then(checkStatus)
            .then(() => alert("Account created successfully!"))
            .catch((err) => alert(`Failed to create an account: ${err.message}`));
    }
    
    /**
     * Displays the fetched card data and populates the card container.
     * @param {object} data - The card data that the user matches with
     */
    function displayCard(data) {    
        if (data.length === 0) {
            alert("No cards found for the given criteria.");
            return;
        }
    
        const card = data[currCard % data.length]; // to cycle through cards
        qs("#name").textContent = card.first_name || "N/A";
        qs("#sport").textContent = card.sport_name || "N/A";
        qs("#experience").textContent = card.experience_level || "N/A";
        qs("#preferred-day").textContent = card.preferred_day || "N/A";
        qs("#state").textContent = card.home_state || "N/A";
        qs("#bio").textContent = card.bio || "N/A";
    
        qs("#card").classList.remove("hidden");
    
        // incremented card index for the next fetch to display next card
        currCard++;
    }
      
    /**
     * Helper function to return the Response data if successful,
     * otherwise returns an Error that needs to be caught.
     * Slightly edited version of utils.js version to implement custom error
     * handling.
     * @param {object} response - response with status to check for success/error.
     * @returns {object} - The Response object if successful, otherwise an Error
     */
    function checkStatus(response) {
        if (!response.ok) {
        let errorMsg = `Error: ${response.status} ${response.statusText}`;
        switch (response.status) {
            case 400:
                errorMsg = "Bad Request: Missing or invalid parameters.";
                break;
            case 401:
                errorMsg = "Unauthorized: Invalid credentials.";
                break;
            case 500:
                errorMsg = "Internal Server Error: Please try again later.";
                break;
        }
        throw new Error(errorMsg);
        }
        return response;
    }

    init();
})();
  