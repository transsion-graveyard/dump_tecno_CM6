
__kernel void color_cross(__global unsigned char *bgr_image,
                           __global float *Matrix,
                           int height,
                           int width)
{
    int col = get_global_id(0);
    int row = get_global_id(1);
    int index = row * width + col;
    float sum = 0.0f;
    float r = (float)bgr_image[index * 3] / 255.0f;
    float g = (float)bgr_image[index * 3 + 1] / 255.0f;
    float b = (float)bgr_image[index * 3 + 2] / 255.0f;
    __private float t[11];
    t[0] = r; t[1] = g; t[2] = b;
    t[3] = r * g; t[4] = r * b; t[5] = g * b; 
    t[6] = r * r; t[7] = g * g; t[8] = b * b;
    t[9] = r * g * b; t[10] = 1.0f;
    __private float sums[3];
    sums[0] = 0.0f; sums[1] = 0.0f; sums[2] = 0.0f;
    for (int j = 0; j < 3; j++)
    {
        for (int i = 0; i < 11; i ++)
        {
            sums[j] += t[i] * Matrix[i * 3 + j];
        }
    }
	float r_matrix, g_matrix, b_matrix;
	b_matrix = sums[0] * 255.0f;
    g_matrix = sums[1] * 255.0f;
    r_matrix = sums[2] * 255.0f;
    
    bgr_image[index * 3] = (unsigned char)(max(min(b_matrix, 255.0f), 0.0f));
    bgr_image[index * 3 + 1] = (unsigned char)(max(min(g_matrix, 255.0f), 0.0f));
    bgr_image[index * 3 + 2] = (unsigned char)(max(min(r_matrix, 255.0f), 0.0f));
}