const readline = require('readline-sync');

const ft_count_harvest_iterative = () => {
    const number_harvest = parseInt(readline.question('Days until harvest : '));
    for (let index = 1; index <= number_harvest; index++)
        console.log(`Day ${index}`);
    console.log('Harvest time !');
};

// ft_count_harvest_iterative();
module.exports = {ft_count_harvest_iterative}