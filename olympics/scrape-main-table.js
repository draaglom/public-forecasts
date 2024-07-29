// forgive me for this gpt code

// Select all rows in the table
let rows = document.querySelectorAll('table')[1].querySelectorAll('tr');

// Use map to extract the team code and number of all-time gold medals from each row
let results = Array.from(rows).map(row => {
  // Select the first <td> in the row
  let firstTd = row.querySelector('td');
  if (firstTd) {
    // Try to select the span with an id
    let spanWithId = firstTd.querySelector('span[id]');
    if (spanWithId) {
      // Extract the team code
      let teamCode = spanWithId.id;

      // Select the <td> containing all-time gold medals, which is the 13th <td> in the row
      let goldMedalsTd = row.querySelectorAll('td')[12];
      if (goldMedalsTd) {
        let goldMedals = parseInt(goldMedalsTd.textContent.trim());

        // Return an object containing the team code and gold medals
        return { teamCode, goldMedals };
      }
    }
  }
  return null; // Return null for rows that do not have the necessary data
}).filter(result => result !== null); // Filter out any null results


const hasMedals = results.filter(result => result.goldMedals > 0).map(result => result.teamCode)
