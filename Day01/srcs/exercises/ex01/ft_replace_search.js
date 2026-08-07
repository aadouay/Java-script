/**
 * @param {string} name
 * @param {string} message
 * @returns {void}
 */

function ft_replace_search(name, message) {
    message.replace('error', 'issue')
    console.log(`Hello ${name}`)
    console.log(message)
    const include = message.includes("urgent")
    console.log(`Contains "urgent" : ${include}`)
}

// ft_replace_search("Sara", "urgent error in the server")

module.exports = ft_replace_search