/**
 * @param {Array <string>} items
 * @returns {void}
 */

function ft_loop_it(items) {
    console.log("- for loop -")
    for (let index = 0; index < items.length; index++) {
        console.log(`${index}: ${items[index]}`)
    }
    console.log("- for...of loop -")
    for(const element of items) {
        console.log(element);
    }
}

// ft_loop_it(["route", "middleware", "controller"])
module.exports = ft_loop_it