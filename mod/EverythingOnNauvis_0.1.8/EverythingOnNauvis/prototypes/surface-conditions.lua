

-- Remove surface conditions for every entry that has surface condition (like buildings, recipes, etc...)
for _, type in pairs(data.raw) do
    for _, name in pairs(type) do
        if name.surface_conditions then
            name.surface_conditions = nil
        end
    end
end
