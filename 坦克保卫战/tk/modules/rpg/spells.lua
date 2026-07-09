local Public = {}

function Public.conjure_items()
    local spells = {}

    spells[#spells + 1] = {
        name = {'entity-name.express-transport-belt'},
        entityName = 'express-transport-belt',
        level = 45,
        type = 'item',
        mana_cost = 150,
        tick = 300,
        enabled = true,
        sprite = 'recipe/express-transport-belt'
    }
    spells[#spells + 1] = {
        name = {'entity-name.express-underground-belt'},
        entityName = 'express-underground-belt',
        level = 40,
        type = 'item',
        mana_cost = 200,
        tick = 300,
        enabled = true,
        sprite = 'recipe/express-underground-belt'
    }
    spells[#spells + 1] = {
        name = {'entity-name.big-sand-rock'},
        entityName = 'big-sand-rock',
        level = 60,
        type = 'entity',
        mana_cost = 100,
        tick = 350,
        enabled = false,
        sprite = 'entity/big-sand-rock'
    }
    spells[#spells + 1] = {
        name = {'entity-name.small-biter'},
        entityName = 'small-biter',
        level = 10,
        biter = true,
        type = 'entity',
        mana_cost = 45,
        tick = 200,
        enabled = true,
        sprite = 'entity/small-biter'
    }
    spells[#spells + 1] = {
        name = {'entity-name.small-spitter'},
        entityName = 'small-spitter',
        level = 10,
        biter = true,
        type = 'entity',
        mana_cost = 45,
        tick = 200,
        enabled = true,
        sprite = 'entity/small-spitter'
    }
    spells[#spells + 1] = {
        name = {'entity-name.medium-biter'},
        entityName = 'medium-biter',
        level = 35,
        biter = true,
        type = 'entity',
        mana_cost = 75,
        tick = 300,
        enabled = true,
        sprite = 'entity/medium-biter'
    }
    spells[#spells + 1] = {
        name = {'entity-name.medium-spitter'},
        entityName = 'medium-spitter',
        level = 35,
        biter = true,
        type = 'entity',
        mana_cost = 75,
        tick = 300,
        enabled = true,
        sprite = 'entity/medium-spitter'
    }
    spells[#spells + 1] = {
        name = {'entity-name.big-biter'},
        entityName = 'big-biter',
        level = 50,
        biter = true,
        type = 'entity',
        mana_cost = 120,
        tick = 300,
        enabled = true,
        sprite = 'entity/big-biter'
    }
    spells[#spells + 1] = {
        name = {'entity-name.big-spitter'},
        entityName = 'big-spitter',
        level = 50,
        biter = true,
        type = 'entity',
        mana_cost = 120,
        tick = 300,
        enabled = true,
        sprite = 'entity/big-spitter'
    }
    spells[#spells + 1] = {
        name = {'entity-name.behemoth-biter'},
        entityName = 'behemoth-biter',
        level = 80,
        biter = true,
        type = 'entity',
        mana_cost = 200,
        tick = 300,
        enabled = true,
        sprite = 'entity/behemoth-biter'
    }
    spells[#spells + 1] = {
        name = {'entity-name.behemoth-spitter'},
        entityName = 'behemoth-spitter',
        level = 80,
        biter = true,
        type = 'entity',
        mana_cost = 200,
        tick = 300,
        enabled = true,
        sprite = 'entity/behemoth-spitter'
    }
    spells[#spells + 1] = {
        name = {'entity-name.small-worm-turret'},
        entityName = 'small-worm-turret',
        level = 35,
        biter = true,
        type = 'entity',
        mana_cost = 200,
        tick = 300,
        enabled = true,
        sprite = 'entity/small-worm-turret'
    }

    spells[#spells + 1] = {
        name = {'entity-name.medium-worm-turret'},
        entityName = 'medium-worm-turret',
        level = 50,
        biter = true,
        type = 'entity',
        mana_cost = 300,
        tick = 300,
        enabled = true,
        sprite = 'entity/medium-worm-turret'
    }

    spells[#spells + 1] = {
        name = {'entity-name.big-worm-turret'},
        entityName = 'big-worm-turret',
        level = 80,
        biter = true,
        type = 'entity',
        mana_cost = 450,
        tick = 300,
        enabled = true,
        sprite = 'entity/big-worm-turret'
    }

    spells[#spells + 1] = {
        name = {'entity-name.behemoth-worm-turret'},
        entityName = 'behemoth-worm-turret',
        level = 120,
        biter = true,
        type = 'entity',
        mana_cost = 700,
        tick = 300,
        enabled = true,
        sprite = 'entity/behemoth-worm-turret'
    }
    spells[#spells + 1] = {
        name = {'entity-name.biter-spawner'},
        entityName = 'biter-spawner',
        level = 90,
        biter = true,
        type = 'entity',
        mana_cost = 500,
        tick = 1420,
        enabled = true,
        sprite = 'entity/biter-spawner'
    }
    spells[#spells + 1] = {
        name = {'entity-name.spitter-spawner'},
        entityName = 'spitter-spawner',
        level = 90,
        biter = true,
        type = 'entity',
        mana_cost = 500,
        tick = 1420,
        enabled = true,
        sprite = 'entity/spitter-spawner'
    }

  
    spells[#spells + 1] = {
        name = {'item-name.slowdown-capsule'},
        entityName = 'slowdown-capsule',
        target = true,
        amount = 1,
        damage = true,
        force = 'player',
        level = 25,
        type = 'item',
        mana_cost = 175,
        tick = 150,
        enabled = true,
        sprite = 'recipe/slowdown-capsule'
    }
    spells[#spells + 1] = {
        name = {'item-name.grenade'},
        entityName = 'grenade',
        target = true,
        amount = 1,
        damage = true,
        force = 'player',
        level = 10,
        type = 'item',
        mana_cost = 50,
        tick = 50,
        enabled = true,
        sprite = 'recipe/grenade'
    }
    spells[#spells + 1] = {
        name = {'item-name.cluster-grenade'},
        entityName = 'cluster-grenade',
        target = true,
        amount = 2,
        damage = true,
        force = 'player',
        level = 30,
        type = 'item',
        mana_cost = 250,
        tick = 200,
        enabled = true,
        sprite = 'recipe/cluster-grenade'
    }
    spells[#spells + 1] = {
        name = {'spells.repair_aoe'},
        entityName = 'repair_aoe',
        target = true,
        amount = 1,
        range = 50,
        damage = false,
        force = 'player',
        level = 45,
        type = 'special',
        mana_cost = 150,
        tick = 100,
        enabled = true,
        sprite = 'recipe/repair-pack'
    }
    spells[#spells + 1] = {
        name = {'spells.raw_fish'},
        entityName = 'raw-fish',
        target = false,
        amount = 4,
        capsule = true,
        damage = false,
        range = 30,
        force = 'player',
        level = 10,
        type = 'special',
        mana_cost = 100,
        tick = 320,
        enabled = true,
        sprite = 'item/raw-fish'
    }
 
    spells[#spells + 1] = {
        name = {'spells.warp'},
        entityName = 'warp-gate',
        target = true,
        force = 'player',
        level = 45,
        type = 'special',
        mana_cost = 400,
        tick = 2000,
        enabled = true,
        sprite = 'virtual-signal/signal-W'
    }
    spells[#spells + 1] = {
        name = {'spells.wudi_turret'},
        itam_code=true,
        entityName = 'wudi_turret',
        insert='firearm-magazine',
        target = true,
        force = 'player',
        level = 35,
        type = 'special',
        mana_cost = 200,
        tick = 100,
        enabled = true,
        sprite = 'recipe/gun-turret'
    }
    spells[#spells + 1] = {
        name = {'spells.biter_special_forces'},
        itam_code=true,
        entityName = 'biter_special_forces',
        target = true,
        force = 'player',
        level = 50,
        type = 'special',
        mana_cost = 250,
        tick = 100,
        enabled = false,
        sprite = 'item/submachine-gun'
    }

    spells[#spells + 1] = {
        name = {'spells.jgq'},
        itam_code=true,
        entityName = 'jgq',
        target = true,
        force = 'player',
        level = 15,
        type = 'special',
        mana_cost = 100,
        tick = 100,
        enabled = true,
        sprite = 'virtual-signal/signal-B'
    }
    spells[#spells + 1] = {
        name = {'spells.ufo'},
        itam_code=true,
        entityName = 'ufo',
        target = true,
        force = 'player',
        level = 100,
        type = 'special',
        mana_cost = 750,
        tick = 100,
        enabled = false,
        sprite = 'virtual-signal/signal-C'
    }
    spells[#spells + 1] = {
        name = {'spells.lightning_chain'},
        itam_code=true,
        entityName = 'lightning_chain',
        target = true,
        force = 'player',
        level = 30,
        type = 'special',
        mana_cost = 200,
        tick = 100,
        enabled = true,
        sprite = 'virtual-signal/signal-L'
    }
    spells[#spells + 1] = {
        name = {'spells.jx'},
        itam_code=true,
        entityName = 'jx',
        target = true,
        force = 'player',
        level = 30,
        type = 'special',
        mana_cost = 350,
        tick = 100,
        enabled = true,
        sprite = 'item/exoskeleton-equipment'
    }
    spells[#spells + 1] = {
        name = {'spells.lyly'},
        itam_code=true,
        entityName = 'lyly',
        target = true,
        force = 'player',
        level = 35,
        type = 'special',
        mana_cost = 75,
        tick = 100,
        enabled = false,
        sprite = 'item/flamethrower-ammo'
    }
    spells[#spells + 1] = {
        name = {'spells.ssz'},
        itam_code=true,
        entityName = 'ssz',
        target = true,
        force = 'player',
        level = 30,
        type = 'special',
        mana_cost = 200,
        tick = 100,
        enabled = true,
        sprite = 'recipe/stone-wall'
    }
    spells[#spells + 1] = {
        name = {'spells.distractor'},
        entityName = 'distractor-capsule',
        target = true,
        amount = 1,
        damage = false,
        range = 30,
        force = 'player',
        level = 25,
        type = 'special',
        mana_cost = 125,
        tick = 320,
        enabled = true,
        sprite = 'recipe/distractor-capsule'
    }
    spells[#spells + 1] = {
        name = {'item-name.atomic-bomb'},
        entityName = 'atomic-bomb',
        range = 64,
        target = true,
        amount = 1,
        damage = true,
        force = 'enemy',
        level = 120,
        type = 'item',
        mana_cost = 1000,
        tick = 0,
        enabled = false,
        sprite = 'virtual-signal/signal-A'
    }
    spells[#spells + 1] = {
        name = {'spells.ch'},
        itam_code=true,
        entityName = 'ch',
        target = true,
        force = 'player',
        level = 15,
        type = 'special',
        mana_cost = 40,
        tick = 100,
        enabled = false,
        sprite = 'entity/small-spitter'
    }
    spells[#spells + 1] = {
        name = {'spells.huo_dun'},
        itam_code=true,
        entityName = 'huo_dun',
        target = true,
        force = 'player',
        level = 20,
        type = 'special',
        mana_cost = 230,
        tick = 200,
        enabled = true,
        sprite = 'item/flamethrower-ammo'
    }
    spells[#spells + 1] = {
        name = {'spells.advanced_fishing'},
        itam_code=true,
        entityName = 'advanced_fishing',
        target = true,
        force = 'player',
        level = 15,
        type = 'special',
        mana_cost = 150,
        tick = 100,
        enabled = true,
        sprite = 'item/raw-fish'
    }
    spells[#spells + 1] = {
        name = {'spells.shui_long_dan'},
        itam_code=true,
        entityName = 'shui_long_dan',
        target = true,
        force = 'player',
        level = 30,
        type = 'special',
        mana_cost = 300,
        tick = 100,
        enabled = true,
        sprite = 'entity/water-splash'
    }
    spells[#spells + 1] = {
        name = {'spells.xiao_jingling'},
        itam_code=true,
        entityName = 'xiao_jingling',
        target = true,
        force = 'player',
        level = 60,
        type = 'special',
        mana_cost = 750,
        tick = 100,
        enabled = false,
        sprite = 'entity/behemoth-spitter'
    }
    spells[#spells + 1] = {
        name = {'spells.huanxing_huoshan_penfa'},
        itam_code=true,
        entityName = 'huanxing_huoshan_penfa',
        target = true,
        force = 'player',
        level = 45,
        type = 'special',
        mana_cost = 400,
        tick = 100,
        enabled = true,
        sprite = 'entity/small-demolisher-fissure-damage-explosion'
    }
    spells[#spells + 1] = {
        name = {'spells.leizhenyu'},
        itam_code=true,
        entityName = 'leizhenyu',
        target = true,
        force = 'player',
        level = 25,
        type = 'special',
        mana_cost = 280,
        tick = 100,
        enabled = true,
        sprite = 'entity/lightning'
    }
    return spells
end

Public.itam_spell = {
      ['wudi_turret'] = {max_range = 36, tick_speed = 1,need_list={1,200,1000},upgrade_list={"firearm-magazine","piercing-rounds-magazine","uranium-rounds-magazine"}},
      ['lightning_chain'] = {max_range = 36, tick_speed = 1,lianxu=true,bonus=1,need_times=50,base=1},
      ['lyly'] = {max_range = 16, tick_speed = 1,lianxu=true,bonus=1,need_times=1,base=1},
      ['jx'] = {max_range = 32, tick_speed = 1,lianxu=true,bonus=1,need_times=1,base=1},
      ['ssz'] = {max_range = 32, tick_speed = 1,lianxu=true,bonus=1,need_times=1,base=1},
      ['ch'] = {max_range = 32, tick_speed = 1,lianxu=true,bonus=1,need_times=40,base=1},
      ['jgq'] = {max_range = 100, tick_speed = 1,lianxu=true,bonus=1,need_times=40,base=8},
      ['ufo'] = {max_range = 100, tick_speed = 1,lianxu=true,bonus=1,need_times=40,base=8},
      ['biter_special_forces'] = {max_range = 36, tick_speed = 1,need_list={1,300,500,1000},upgrade_list={"1","2","3","4"}},
      ['huo_dun'] = {max_range = 42, tick_speed = 1,lianxu=true,bonus=1,need_times=50,base=1},
      ['advanced_fishing'] = {max_range = 100, tick_speed = 1,lianxu=true,bonus=1,need_times=100,base=1},
      ['shui_long_dan'] = {max_range = 42, tick_speed = 1,lianxu=true,bonus=1,need_times=50,base=1},
      ['xiao_jingling'] = {max_range = 32, tick_speed = 1,lianxu=true,bonus=1,need_times=50,base=1},
      ['huanxing_huoshan_penfa'] = {max_range = 36, tick_speed = 1,lianxu=true,bonus=1,need_times=50,base=1},
      ['leizhenyu'] = {max_range = 42, tick_speed = 1,lianxu=true,bonus=1,need_times=50,base=1},
}

Public.projectile_types = {
    ['explosives'] = {name = 'grenade', count = 0.5, max_range = 32, tick_speed = 1},
    ['land-mine'] = {name = 'grenade', count = 1, max_range = 32, tick_speed = 1},
    ['grenade'] = {name = 'grenade', count = 1, max_range = 40, tick_speed = 1},
    ['cluster-grenade'] = {name = 'cluster-grenade', count = 1, max_range = 40, tick_speed = 3},
    ['artillery-shell'] = {name = 'artillery-projectile', count = 1, max_range = 60, tick_speed = 3},
    ['cannon-shell'] = {name = 'cannon-projectile', count = 1, max_range = 60, tick_speed = 1},
    ['explosive-cannon-shell'] = {name = 'explosive-cannon-projectile', count = 1, max_range = 60, tick_speed = 1},
    ['explosive-uranium-cannon-shell'] = {
        name = 'explosive-uranium-cannon-projectile',
        count = 1,
        max_range = 60,
        tick_speed = 1
    },
    ['uranium-cannon-shell'] = {name = 'uranium-cannon-projectile', count = 1, max_range = 60, tick_speed = 1},
    ['atomic-bomb'] = {name = 'atomic-rocket', count = 1, max_range = 64, tick_speed = 1},
    ['explosive-rocket'] = {name = 'explosive-rocket', count = 1, max_range = 48, tick_speed = 1},
    ['rocket'] = {name = 'rocket', count = 1, max_range = 48, tick_speed = 1},
    ['flamethrower-ammo'] = {name = 'flamethrower-fire-stream', count = 4, max_range = 28, tick_speed = 1},
    ['crude-oil-barrel'] = {name = 'flamethrower-fire-stream', count = 3, max_range = 24, tick_speed = 1},
    ['petroleum-gas-barrel'] = {name = 'flamethrower-fire-stream', count = 4, max_range = 24, tick_speed = 1},
    ['light-oil-barrel'] = {name = 'flamethrower-fire-stream', count = 4, max_range = 24, tick_speed = 1},
    ['heavy-oil-barrel'] = {name = 'flamethrower-fire-stream', count = 4, max_range = 24, tick_speed = 1},
    ['acid-stream-spitter-big'] = {
        name = 'acid-stream-spitter-big',
        count = 3,
        max_range = 16,
        tick_speed = 1,
        force = 'enemy'
    },
    ['lubricant-barrel'] = {name = 'acid-stream-spitter-big', count = 3, max_range = 16, tick_speed = 1},
    ['shotgun-shell'] = {name = 'shotgun-pellet', count = 16, max_range = 24, tick_speed = 1},
    ['piercing-shotgun-shell'] = {name = 'piercing-shotgun-pellet', count = 16, max_range = 24, tick_speed = 1},
    ['firearm-magazine'] = {name = 'shotgun-pellet', count = 16, max_range = 24, tick_speed = 1},
    ['piercing-rounds-magazine'] = {name = 'piercing-shotgun-pellet', count = 16, max_range = 24, tick_speed = 1},
    ['uranium-rounds-magazine'] = {name = 'piercing-shotgun-pellet', count = 32, max_range = 24, tick_speed = 1},
    ['cliff-explosives'] = {name = 'cliff-explosives', count = 1, max_range = 48, tick_speed = 2}
}

return Public
