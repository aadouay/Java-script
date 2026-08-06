const readline = require('readline-sync')

const garden_name = () => {
    const first_name = readline.question("Enter garden name : ");
    console.log(`Garden : ${first_name}`);
    console.log("Status : Growing well !");
};

// garden_name();

module.exports = { garden_name };