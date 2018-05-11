"use strict";
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (Object.hasOwnProperty.call(mod, k)) result[k] = mod[k];
    result["default"] = mod;
    return result;
};
Object.defineProperty(exports, "__esModule", { value: true });
const rl = __importStar(require("readline-sync"));
var Colour;
(function (Colour) {
    Colour[Colour["Black"] = 0] = "Black";
    Colour[Colour["Red"] = 1] = "Red";
    Colour[Colour["Green"] = 2] = "Green";
    Colour[Colour["Blue"] = 3] = "Blue";
})(Colour || (Colour = {}));
var Resources;
(function (Resources) {
    Resources.empty = { red: 0, green: 0, blue: 0 };
    function of_string_exn(s) {
        const [red, green, blue] = s.split(' ').map(x => parseInt(x));
        return { red, green, blue };
    }
    Resources.of_string_exn = of_string_exn;
    function to_string(t1) {
        return `((red ${t1.red}) (green ${t1.green}) (blue ${t1.blue}))`;
    }
    Resources.to_string = to_string;
    function subsumes(t1, t2) {
        return (t1.red <= t2.red &&
            t1.green <= t2.green &&
            t1.blue <= t2.blue);
    }
    Resources.subsumes = subsumes;
    function add(t1, t2) {
        return {
            red: t1.red + t2.red,
            green: t1.green + t2.green,
            blue: t1.blue + t2.blue,
        };
    }
    Resources.add = add;
    function subtract(t1, t2) {
        return {
            red: t1.red - t2.red,
            green: t1.green - t2.green,
            blue: t1.blue - t2.blue,
        };
    }
    Resources.subtract = subtract;
})(Resources || (Resources = {}));
var UnitKind;
(function (UnitKind) {
    UnitKind.general = {
        name: 'General',
        colour: Colour.Black,
        health: 5,
        width: 1,
        attack: [1],
        cost: null,
        before_turn: null,
    };
    UnitKind.grunt = {
        name: 'Grunt',
        colour: Colour.Red,
        health: 1,
        width: 1,
        attack: [1],
        cost: { red: 2, green: 0, blue: 0 },
        before_turn: null,
    };
    UnitKind.font_r = {
        name: 'Font R',
        colour: Colour.Red,
        health: 2,
        width: 1,
        attack: [],
        cost: { red: 1, green: 0, blue: 2 },
        before_turn: player => { player.resources.red += 1; },
    };
})(UnitKind || (UnitKind = {}));
const UnitKinds = {
    general: UnitKind.general,
    grunt: UnitKind.grunt,
    font_r: UnitKind.font_r,
};
var Unit;
(function (Unit) {
    function create(kind) {
        return {
            kind,
            hp: kind.health,
        };
    }
    Unit.create = create;
    function to_string(unit) {
        return (`(${unit.kind.name}` +
            ` (width ${unit.kind.width})` +
            ` (hp ${unit.hp}/${unit.kind.health})` +
            (unit.kind.attack.length ? ` (attack ${unit.kind.attack}))` : ''));
    }
    Unit.to_string = to_string;
})(Unit || (Unit = {}));
var Player;
(function (Player) {
    function create(name, production) {
        return {
            name,
            units: [Unit.create(UnitKind.general)],
            resources: Resources.empty,
            production,
            done_turn: false,
            alive: true,
        };
    }
    Player.create = create;
})(Player || (Player = {}));
var GameState;
(function (GameState) {
    GameState.empty = {
        players: [],
        turn: 0,
    };
})(GameState || (GameState = {}));
function sum(xs) {
    return xs.reduce((a, b) => a + b);
}
// lower inclusive, upper exclusive
function rand_int(lower, upper) {
    return Math.floor(Math.random() * (upper - lower)) + lower;
}
let state = GameState.empty;
console.log('Starting game.');
function read_production(player_name) {
    while (true) {
        const production = Resources.of_string_exn(rl.question(`${player_name}'s production (R G B): `));
        if (production.red + production.blue + production.green !== 7) {
            console.log('Must sum to 7');
            continue;
        }
        return production;
    }
}
['Alice', 'Bob'].forEach(name => {
    state.players.push(Player.create(name, read_production(name)));
});
while (true) {
    // Production
    for (let pid = 0; pid < 2; pid += 1) {
        const player = state.players[pid];
        player.resources = Resources.add(player.resources, player.production);
    }
    // Pre-turn effects
    state.players.forEach(player => {
        player.units.forEach(unit => {
            if (unit.kind.before_turn !== null) {
                unit.kind.before_turn(player);
            }
        });
    });
    // Build
    for (let pid = 0; pid < 2; pid += 1) {
        console.log(`Player ${pid + 1}`);
        const player = state.players[pid];
        while (true) {
            console.log(`Resources available: ${Resources.to_string(player.resources)}`);
            console.log(`Your units:\n${player.units.map(u => Unit.to_string(u)).join('\n')}`);
            const cmd = rl.question('> ');
            if (cmd === 'done')
                break;
            const unit_kind = UnitKinds[cmd];
            if (unit_kind === undefined) {
                console.log('Invalid unit.');
                continue;
            }
            if (unit_kind.cost === null) {
                console.log('Cannot buy.');
                continue;
            }
            if (!Resources.subsumes(unit_kind.cost, player.resources)) {
                console.log('Cannot afford.');
                continue;
            }
            player.resources = Resources.subtract(player.resources, unit_kind.cost);
            player.units.push(Unit.create(unit_kind));
        }
    }
    // Battle
    for (let attacker_id = 0; attacker_id < 2; attacker_id += 1) {
        const defender_id = (attacker_id + 1) % 2;
        const attacker = state.players[attacker_id];
        const defender = state.players[defender_id];
        const total_width = sum(defender.units.map(u => u.kind.width));
        attacker.units.forEach(u => {
            u.kind.attack.forEach(atk => {
                const target = defender.units[rand_int(0, total_width)];
                target.hp -= atk;
                console.log(`${attacker.name}'s ${u.kind.name}` +
                    ` attacks ${defender.name}'s ${target.kind.name}` +
                    ` for ${atk}.`);
            });
        });
    }
    // Reaping
    for (let pid = 0; pid < 2; pid += 1) {
        const player = state.players[pid];
        let player_lost = false;
        player.units = player.units.filter(u => {
            if (u.hp > 0) {
                return true;
            }
            if (u.kind === UnitKind.general) {
                player_lost = true;
            }
            console.log(`${player.name}'s ${u.kind.name} died!`);
            return false;
        });
        if (player_lost) {
            console.log(`${player.name} is so ded!`);
            player.alive = false;
        }
    }
    // Check for win
    const remaining_players = state.players.filter(p => p.alive);
    if (remaining_players.length < 2) {
        if (remaining_players.length === 1) {
            console.log(`${remaining_players[0].name} wins!`);
        }
        else {
            console.log('It is a tie!');
        }
        break;
    }
}
console.log('Play again some time!');
