#version 330

// raylibのデフォルト頂点シェーダーから自動で渡される変数（名前は固定）
in vec2 fragTexCoord;
in vec4 fragColor;

// raylibから自動で渡されるテクスチャとカラー（名前は固定）
uniform sampler2D texture0;
uniform vec4 colDiffuse;

// 自分で追加したUniform変数（Odin側から値を送る）
uniform float uTime;

// 最終的に画面に出力するピクセルの色
out vec4 finalColor;

void main()
{
    // 元のテクスチャ（または図形）の色を取得
    vec4 texelColor = texture(texture0, fragTexCoord);

    // 時間（uTime）とUV座標を使ってRGBを計算
    vec3 rainbow = 0.5 + 0.5 * cos(uTime + fragTexCoord.xyx + vec3(0.0, 2.0, 4.0));

    // 元の色と掛け合わせて出力
    finalColor = vec4(rainbow, 1.0) * texelColor * fragColor * colDiffuse;
}
