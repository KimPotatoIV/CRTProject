// Godot에서 이 셰이더가 2D 노드에 적용됨을 의미
// 이 셰이더는 화면의 픽셀 단위로 계산할 거라는 뜻
shader_type canvas_item;

const vec2 VIEWPORT_SIZE = vec2(640.0, 360.0);

// uniform -> 외부에서 값을 바꿀 수 있는 변수
// hint_range(a, b) -> Inspector에서 슬라이더로 조절 가능하게 함

// 스캔라인 어둡게 하는 정도
uniform float scanline_strength : hint_range(0.0, 1.0) = 0.15;
// RGB 색을 좌우로 분리하는 거리
uniform float rgb_offset : hint_range(0.0, 3.0) = 1.0;
// 스캔라인 줄 간격
uniform float scanline_frequency : hint_range(0.1, 3.0) = 2.0;
// 블러 효과 강도
uniform float blur_strength : hint_range(0.0, 1.0) = 0.25;

// GPU가 렌더링할 픽셀 하나의 색상과 특성을 결정하는 핵심 함수
void fragment() {
	// UV는 현재 픽셀의 좌표를 0~1 범위로 정규화한 값
	// (0,0) -> 화면 왼쪽 위
	// (1,1) -> 화면 오른쪽 아래
	vec2 uv = UV;
	
	// CRT 느낌으로 RGB가 조금씩 어긋나는 효과
	// UV는 픽셀이 아닌 0~1 범위라서 실제 픽셀 이동을 하려면 화면 크기로 나눠야 함
	// 화면 가로 1920px 이면, 한 픽셀 이동은 UV로 1/1920만큼 이동하는 것과 같음
	vec2 offset = vec2(rgb_offset / VIEWPORT_SIZE.x, 0.0);
	// texture(TEXTURE, uv +- offset) -> 화면 텍스처에서 픽셀 색 가져오기
	float r = texture(TEXTURE, uv + offset).r;
	float g = texture(TEXTURE, uv).g;
	float b = texture(TEXTURE, uv - offset).b;
	// color = vec3(r, g, b)로 분리한 RGB 합치기
	vec3 color = vec3(r, g, b);
	
	// 블러(Blur) 처리
	// blur -> 한 픽셀 거리 기준으로 UV 좌표 변환
	vec2 blur = vec2(1.0 / VIEWPORT_SIZE.x, 1.0 / VIEWPORT_SIZE.y);
	vec3 blur_color = (
		texture(TEXTURE, uv + vec2(-blur.x, -blur.y)).rgb +
		texture(TEXTURE, uv - vec2(blur.x, -blur.y)).rgb +
		texture(TEXTURE, uv + vec2(blur.x, blur.y)).rgb +
		texture(TEXTURE, uv + vec2(-blur.x, 0.0)).rgb +
		texture(TEXTURE, uv).rgb +
		texture(TEXTURE, uv + vec2(blur.x, 0.0)).rgb +
		texture(TEXTURE, uv + vec2(-blur.x, blur.y)).rgb + 
		texture(TEXTURE, uv + vec2(0.0, blur.y)).rgb + 
		texture(TEXTURE, uv + vec2(blur.x, blur.y)).rgb
		) * (1.0 / 9.0);
	
	// 원래 색(color)과 블러 색(blur_color)을 섞음
	color = mix(color, blur_color, blur_strength);
	
	// UV.y -> 현재 픽셀의 세로 위치(0~1)
	// UV.y * VIEWPORT_SIZE.y -> 실제 픽셀 단위 Y 좌표
	// scanline_frequency -> 값이 크면 줄 간격이 좁아지고, 작으면 줄 간격이 넓어짐
	// scanline_strength -> 사인 진폭 조절
	// scan은 세로 위치 기준 밝기 조정 값
	float scan = 
		sin(UV.y * VIEWPORT_SIZE.y * scanline_frequency) * scanline_strength;
	// RGB 색상은 0~1 범위이고 0 -> 완전 검정, 1 -> 최대 밝기이므로
	// scan을 뺀 만큼의 값을 곱하면 일정 크기만큼 어두워짐
	color *= 1.0 - scan;
	
	// 최종 픽셀 색상을 RGBA 형식으로 GPU에 출력
	COLOR = vec4(color, 1.0);
}