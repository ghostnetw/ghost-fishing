local seconds, minutes = 1000, 60000
Config = {}

Config.sellShop = {
    enabled = true,
    coords = vec3(-1854.3, -1228.91, 13.0),
    blip = {
        enabled = true,
        sprite = 68,
        color = 3,
        scale = 0.7,
        label = "Fish Market"
    },
    shopItems = {
        fishingrod = {
            label = "Fishing Rod",
            price = 500,
            icon = 'fa-solid fa-fish'
        },
        fishbait = {
            label = "Fish Bait",
            price = 50,
            icon = 'fa-solid fa-bug'
        }
    }
}

Config.bait = {
    itemName = 'fishbait',
    loseChance = 65
}

Config.fishingRod = {
    itemName = 'fishingrod',
    breakChance = 25
}

Config.timeForBite = {
    min = 2 * seconds,
    max = 20 * seconds
}

Config.fish = {
    { item = 'tuna', label = 'Tuna', price = {300, 550}, difficulty = {'medium', 'easy', 'easy'} },
    { item = 'salmon', label = 'Salmon', price = {235, 300}, difficulty = {'medium', 'easy'} },
    { item = 'trout', label = 'Trout', price = {190, 235}, difficulty = {'easy', 'easy'} },
    { item = 'anchovy', label = 'Anchovy', price = {100, 190}, difficulty = {'easy'} },
    { item = 'bass', label = 'Bass', price = {150, 250}, difficulty = {'medium', 'easy'} },
}

Config.notifications = {
    no_money = "Not enough money!",
    bought_item = "You bought %s",
    sold_fish = "Sold %s fish for $%s",
    no_fish = "You don't have any fish to sell!"
}
