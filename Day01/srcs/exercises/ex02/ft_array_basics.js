/**
 * @param {Array} items
 * @returns {void}
 */

function ft_array_basics(items) {
    const length = items.length
    const first_item = items[0]
    const last_item = items[length - 1]

    console.log(`Length: ${length}`)
    console.log(`First : ${first_item}`)
    console.log(`Last: ${last_item}`)
}

// ft_array_basics(["GET", "POST", "PUT", "DELETE"])
module.exports = ft_array_basics