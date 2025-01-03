Config = Config or {}
Locales = Locales or {}
Config.Framework = 'qbcore' -- Change to 'qbcore' if using QBCore
Config.Locale = 'en' -- Default language ('en')

function _U(key)
    return Locales[Config.Locale][key] or key
end

Config.blipInfo = {
    name = 'Bank',
    sprite = 108,
    color = 2,
    scale = 0.55
}

Config.locations = {
    vector3(149.05, -1041.3, 29.37),
    vector3(313.32, -280.03, 54.17),
    vector3(-351.94, -50.72, 49.04),
    vector3(-1212.68, -331.83, 37.78),
    vector3(-2961.67, 482.31, 15.7),
    vector3(1175.64, 2707.71, 38.09),
    vector3(247.65, 223.87, 106.29),
    vector3(-111.98, 6470.56, 31.63)
}