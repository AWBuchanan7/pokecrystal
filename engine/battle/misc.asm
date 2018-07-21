_DisappearUser:
	xor a
	ld [hBGMapMode], a
	ld a, [hBattleTurn]
	and a
	jr z, .player
	call GetEnemyFrontpicCoords
	jr .okay
.player
	call GetPlayerBackpicCoords
.okay
	call ClearBox
	jr FinishAppearDisappearUser

_AppearUserRaiseSub:
	farcall BattleCommand_RaiseSubNoAnim
	jr AppearUser

_AppearUserLowerSub:
	farcall BattleCommand_LowerSubNoAnim

AppearUser:
	xor a
	ld [hBGMapMode], a
	ld a, [hBattleTurn]
	and a
	jr z, .player
	call GetEnemyFrontpicCoords
	xor a
	jr .okay
.player
	call GetPlayerBackpicCoords
	ld a, $31
.okay
	ld [hGraphicStartTile], a
	predef PlaceGraphic
FinishAppearDisappearUser:
	ld a, $1
	ld [hBGMapMode], a
	ret

GetEnemyFrontpicCoords:
	hlcoord 12, 0
	lb bc, 7, 7
	ret

GetPlayerBackpicCoords:
	hlcoord 2, 6
	lb bc, 6, 6
	ret

DoWeatherModifiers:
	ld de, WeatherTypeModifiers
	ld a, [wBattleWeather]
	ld b, a
	ld a, [wd265] ; move type
	ld c, a

.CheckWeatherType:
	ld a, [de]
	inc de
	cp $ff
	jr z, .done_weather_types

	cp b
	jr nz, .NextWeatherType

	ld a, [de]
	cp c
	jr z, .ApplyModifier

.NextWeatherType:
	inc de
	inc de
	jr .CheckWeatherType

.done_weather_types
	ld de, WeatherMoveModifiers

	ld a, BATTLE_VARS_MOVE_EFFECT
	call GetBattleVar
	ld c, a

.CheckWeatherMove:
	ld a, [de]
	inc de
	cp $ff
	jr z, .done

	cp b
	jr nz, .NextWeatherMove

	ld a, [de]
	cp c
	jr z, .ApplyModifier

.NextWeatherMove:
	inc de
	inc de
	jr .CheckWeatherMove

.ApplyModifier:
	xor a
	ld [hMultiplicand + 0], a
	ld hl, wCurDamage
	ld a, [hli]
	ld [hMultiplicand + 1], a
	ld a, [hl]
	ld [hMultiplicand + 2], a

	inc de
	ld a, [de]
	ld [hMultiplier], a

	call Multiply

	ld a, 10
	ld [hDivisor], a
	ld b, $4
	call Divide

	ld a, [hQuotient + 0]
	and a
	ld bc, -1
	jr nz, .Update

	ld a, [hQuotient + 1]
	ld b, a
	ld a, [hQuotient + 2]
	ld c, a
	or b
	jr nz, .Update

	ld bc, 1

.Update:
	ld a, b
	ld [wCurDamage], a
	ld a, c
	ld [wCurDamage + 1], a

.done
	ret

INCLUDE "data/battle/weather_modifiers.asm"

DoBadgeTypeBoosts:
	ld a, [wLinkMode]
	and a
	ret nz

	ld a, [wInBattleTowerBattle]
	and a
	ret nz

	ld a, [hBattleTurn]
	and a
	ret nz

	push de
	push bc

	ld hl, BadgeTypeBoosts

	ld a, [wKantoBadges]
	ld b, a
	ld a, [wJohtoBadges]
	ld c, a

.CheckBadge:
	ld a, [hl]
	cp -1
	jr z, .done

	srl b
	rr c
	jr nc, .NextBadge

	ld a, [wd265] ; move type
	cp [hl]
	jr z, .ApplyBoost

.NextBadge:
	inc hl
	jr .CheckBadge

.ApplyBoost:
	ld a, [wCurDamage]
	ld h, a
	ld d, a
	ld a, [wCurDamage + 1]
	ld l, a
	ld e, a

	srl d
	rr e
	srl d
	rr e
	srl d
	rr e

	ld a, e
	or d
	jr nz, .done_min
	ld e, 1

.done_min
	add hl, de
	jr nc, .Update

	ld hl, $ffff

.Update:
	ld a, h
	ld [wCurDamage], a
	ld a, l
	ld [wCurDamage + 1], a

.done
	pop bc
	pop de
	ret

INCLUDE "data/types/badge_type_boosts.asm"
