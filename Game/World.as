
class World
{
    uint world_width = 512;
    uint world_depth = 512;
    uint world_height = 64;
	uint world_width_depth = world_width * world_depth;
	uint world_size = world_width_depth * world_height;

    uint chunk_width = 16;
    uint chunk_depth = 16;
    uint chunk_height = 16;

	uint chunk_map_width = world_width / chunk_width;
    uint chunk_map_depth = world_depth / chunk_depth;
    uint chunk_map_height = world_height / chunk_height;
	
	uint8[] map;
	uint8[] faces_bits;

	Chunk@[] chunks;

	World()
    {
        map.clear();
		map.resize(world_size);
        faces_bits.clear();
		faces_bits.resize(world_size);
        chunks.clear();
		chunks.resize(chunk_map_width * chunk_map_depth * chunk_map_height);

		uint chunk_i = 0;
		for(int y = 0; y < chunk_map_height; y++)
		{
			for(int z = 0; z < chunk_map_depth; z++)
			{
				for(int x = 0; x < chunk_map_width; x++)
				{
					Chunk chunk;
					chunk.x_start = x * chunk_width;
					chunk.z_start = z * chunk_depth;
					chunk.y_start = y * chunk_height;

					chunk.x_end = chunk.x_start + chunk_width;
					chunk.z_end = chunk.z_start + chunk_depth;
					chunk.y_end = chunk.y_start + chunk_height;

					@chunks[chunk_i] = @chunk;
					chunk_i++;
				}
			}
		}
		//Print("chunk_i: "+chunk_i);
    }
}

class Chunk
{
	uint x_start;
	uint y_start;
	uint z_start;

	uint x_end;
	uint y_end;
	uint z_end;

	SMesh mesh;

	Chunk()
	{

	}
}