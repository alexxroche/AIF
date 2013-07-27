#!/bin/bash
. ticktick.sh

``
  people = {
    "Writers": [
      "Rod Serling",
      "Charles Beaumont",
      "Richard Matheson"
    ],
    "Cast": {
      "Rod Serling": { "Episodes": 156 },
      "Martin Landau": { "Episodes": 2 },
      "William Shatner": { "Episodes": 2 }
    }
  }
``

function printDirectors() {
  echo "  The ``people.Directors.length()`` Directors are:"

  for director in ``people.Directors.items()``; do
    printf "    - %s\n" ${!director}
  done
}

`` people.Directors = [ "John Brahm", "Douglas Heyes" ] ``
printDirectors

newDirector="Lamont Johnson"
`` people.Directors.push($newDirector) ``
printDirectors

echo "Shifted: "``people.Directors.shift()``
printDirectors

echo "Popped: "``people.Directors.pop()``
printDirectors
