* ALFTracker Tool
* FTA, 1991
* Willy Huey, 1989
* Brutal Deluxe, 2015

_ALFBootInit	mac
	Tool	$01E2
	<<<

~ALFStartUp	mac
	PHW	]1
_ALFStartUp	mac
	Tool	$02E2
	<<<

_ALFShutDown	mac
	Tool	$03E2
	<<<

~ALFVersion	mac
	phd	; WordResult
_ALFVersion	mac
	Tool	$04E2
	<<<

_ALFReset	mac
	Tool	$05E2
	<<<

~ALFStatus	mac
	phd	; WordResult
_ALFStatus	mac
	Tool	$06E2
	<<<

~ALFLoadOneMusic	mac
	PHL	]1
_ALFLoadOneMusic	mac
	Tool	$09E2
	<<<

~ALFPlayMusic	mac
	PHW	]1
_ALFPlayMusic	mac
	Tool	$0AE2
	<<<

_ALFStopMusic	mac
	Tool	$0BE2
	<<<

~ALFGetEOfMusic	mac
	phd	; WordResult
_ALFGetEOfMusic	mac
	Tool	$0CE2
	<<<

~ALFAddToBatch	mac
	PHLW	]1;]2
_ALFAddToBatch	mac
	Tool	$0DE2
	<<<

~ALFSelectBatch	mac
	PHW	]1
_ALFSelectBatch	mac
	Tool	$0EE2
	<<<

~ALFKillBatch	mac
	PHW	]1
_ALFKillBatch	mac
	Tool	$0FE2
	<<<

~ALFGetPlayingMusic	mac
	phd	; WordResult
_ALFGetPlayingMusic	mac
	Tool	$10E2
	<<<

~ALFPlayBatch	mac
	PHL	]1
_ALFPlayBatch	mac
	Tool	$11E2
	<<<

~ALFGetTrackVu	mac
	phd	;Long
	phd	;    Result
_ALFGetTrackVu	mac
	Tool	$12E2
	<<<

_ALFPauseMusic	mac
	Tool	$13E2
	<<<

_ALFContinueMusic	mac
	Tool	$14E2
	<<<

_ALFinternal15	mac
	Tool	$15E2
	<<<

_ALFinternal16	mac
	Tool	$16E2
	<<<
