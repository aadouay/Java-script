const readline = require('readline-sync')

const ft_count_harvest_recursive = () => {

    let inputNumber = parseInt(readline.question("Days until harvest : "))
    let index = 1

    function temp(number) {
        if (number > inputNumber)
            return
        console.log("Day " + number)
        temp(++index)
    }
    temp(index)

    console.log(`Harvest time !`)
}

// ft_count_harvest_recursive()

module.exports = {ft_count_harvest_recursive}
