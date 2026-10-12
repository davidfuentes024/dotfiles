// Note file format shared by every Notes window: "# Title\n\nbody"
.pragma library

function parse(text) {
    const lines = (text || "").split("\n");
    if (lines[0].startsWith("# ")) {
        let rest = lines.slice(1);
        if (rest.length > 0 && rest[0] === "") rest = rest.slice(1);
        return { title: lines[0].slice(2).trim(), body: rest.join("\n") };
    }
    return { title: "", body: text || "" };
}

// No title typed: the first line of the text becomes the title
function compose(title, body) {
    const effective = title.trim() || body.trim().split("\n")[0].trim().slice(0, 80);
    if (effective === "") return "";
    const rest = title.trim() ? body : body.trim().split("\n").slice(1).join("\n").replace(/^\n+/, "");
    return "# " + effective + "\n\n" + rest;
}

// Title shown in the list; notes without a heading use their first line
function listTitle(text) {
    return parse(text).title || (text || "").trim().split("\n")[0].trim() || "New note";
}
