# SortLeaderboard

[Back to the recipe catalog](../README.md).

```sx
use STD.Algorithms.Sort

struct Score {
    let player:str
    let points:int
}

func higher(left:@Score, right:@Score) bool {
    return left.points > right.points
}

func main() {
    var scores:Score[] = [
        Score(player:"Ada", points:12),
        Score(player:"Linus", points:9),
        Score(player:"Grace", points:15),
    ]
    Sort.sort<Score>(&scores[0:scores.count()], higher)
    for score in scores { print("$(score.player): $(score.points)") }
}
```
