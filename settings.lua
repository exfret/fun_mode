data:extend({
    {
        type = "bool-setting",
        name = "fun_mode_enable_factoriopedia",
        localised_name = "Force enable factoriopedia",
        order = "a",
        setting_type = "startup",
        default_value = false
    },
    -- Hidden since it's not currently maintained afaik
    {
        type = "bool-setting",
        name = "fun_mode_normal_visuals",
        localised_name = "Normal Visuals",
        localised_description = "Removes visual changes without big gameplay impacts that may be upsetting to some users, such as undulating assembling machines.",
        order = "b",
        setting_type = "startup",
        default_value = false,
        hidden = true,
    },
    {
        type = "bool-setting",
        name = "fun_mode_permanence",
        localised_name = "Permanence challenge",
        order = "b",
        setting_type = "startup",
        default_value = true
    },

    {
        type = "bool-setting",
        name = "fun_mode_dosh",
        localised_name = "Secret password",
        order = "c",
        setting_type = "startup",
        default_value = false
    },
    --[[{
        type = "bool-setting",
        name = "fun_mode_beta",
        localised_name = "Beta features",
        localised_description = "Enable beta features that may not be fully tested.",
        order = "c",
        setting_type = "startup",
        default_value = false
    }]]
})