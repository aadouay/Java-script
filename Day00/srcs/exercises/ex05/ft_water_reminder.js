const readline = require('readline-sync')

const ft_water_reminder = () => {
    const days_since = parseInt(readline.question("Days since last watering : "));

    if(days_since > 2)
        console.log("Water the plants!");
    else
        console.log("Plants are fine.");
};

// ft_water_reminder();

module.exports = { ft_water_reminder };