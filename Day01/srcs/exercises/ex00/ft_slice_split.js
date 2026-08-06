/**
 * @param {string} sentence
 * @returns {void}
 */

function ft_slice_split(sentence) {
    const words = sentence.split(" ")
    const first_word = words.slice(0, 1)
    console.log(`First word: ${first_word}`)
    const motsAvecQuotes = words.map(s => `'${s}'`)
    console.log(`Words: [ ${motsAvecQuotes.join(", ")} ]`)
}

// ft_slice_split("Node handles many requests");

module.exports = { ft_slice_split };