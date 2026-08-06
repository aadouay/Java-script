// const readline = require('readline-sync')

/**
 * @param {string} seedType
 * @param {number} quantity
 * @param {string} unit
 * @returns {void}
 */

function ft_seed_inventory(seedType, quantity, unit) {
    if (unit === 'packets')
        console.log(`${seedType} seeds: ${quantity} ${unit} available.`);
    else if (unit === 'grams')
        console.log(`${seedType} seeds: ${quantity} ${unit} total`);
    else if (unit === 'area')
        console.log(`${seedType} seeds: covers ${quantity} square meters`);
    else
        console.log("Unknown unit type");
}

// ft_seed_inventory("Tomato", 15, "packets");
module.exports = ft_seed_inventory