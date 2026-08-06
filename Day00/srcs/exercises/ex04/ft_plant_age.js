const readline = require('readline-sync')

const ft_plant_age = () => {
    const palnt_age = parseInt(readline.question('Enter plant age in days : '));

    if(palnt_age > 60)
        console.log('Plant is ready to harvest !');
    else
        console.log('Plant is not ready yet.');
};

// ft_plant_age();

module.exports = { ft_plant_age };