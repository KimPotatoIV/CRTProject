extends Node2D

##################################################
@onready var sub_viewport_node: SubViewport = $SubViewportContainer/SubViewport
@onready var texture_rect_node: TextureRect = $TextureRect

##################################################
func _ready() -> void:
	# 일부러 픽셀을 뿌옇게 처리하기 위해 Linear 필터 + Mipmap 사용
	sub_viewport_node.canvas_item_default_texture_filter = \
		Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	# get_texture()		-> SubViewport에서 렌더링된 내용을 Texture 형태로 반환
	# TextureRect에 적용	-> 화면에 SubViewport 내용을 그대로 표시
	texture_rect_node.texture = sub_viewport_node.get_texture()

##################################################
