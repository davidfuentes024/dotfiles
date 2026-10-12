// Fuzzy matching for the launcher: every query character must appear in order.
// Consecutive matches and matches at word starts score higher; -1 = no match.
.pragma library

function score(query, text) {
    if (!text) return -1;
    const q = query.toLowerCase();
    const t = text.toLowerCase();
    if (q.length === 0) return 0;

    const direct = t.indexOf(q);
    if (direct === 0) return 1000 - t.length;
    if (direct > 0) return 800 - direct - t.length;

    let total = 0;
    let streak = 0;
    let position = 0;
    for (const char of q) {
        const found = t.indexOf(char, position);
        if (found === -1) return -1;
        const wordStart = found === 0 || " -_./".includes(t[found - 1]);
        streak = found === position ? streak + 1 : 0;
        total += 10 + streak * 5 + (wordStart ? 15 : 0) - (found - position);
        position = found + 1;
    }
    return total;
}

// Best score of the query against several fields, weighting the first ones more
function best(query, fields) {
    let result = -1;
    fields.forEach((field, index) => {
        const value = score(query, field);
        if (value >= 0) result = Math.max(result, value - index * 50);
    });
    return result;
}
