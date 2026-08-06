const readline = require('readline-sync')

const ft_plot_area = () => {
    const length = readline.question('Enter length: ');
    const width = readline.question('Enter width: ');

    const area = parseInt(length) * parseInt(width);
    console.log(`Plot area : ${area}`);
};

// ft_plot_area();

module.exports = { ft_plot_area };