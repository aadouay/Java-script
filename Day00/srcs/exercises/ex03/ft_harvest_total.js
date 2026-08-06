const readline = require('readline-sync')

const ft_harvest_total = () => {
    const weight_day1 = parseInt(readline.question('Day 1 harvest : '));
    const weight_day2 = parseInt(readline.question('Day 2 harvest : '));
    const weight_day3 = parseInt(readline.question('Day 3 harvest : '));

    const total_weight = weight_day1 + weight_day2 + weight_day3;
    console.log(`Total harvest : ${total_weight}`);
};

// ft_harvest_total();

module.exports = { ft_harvest_total };