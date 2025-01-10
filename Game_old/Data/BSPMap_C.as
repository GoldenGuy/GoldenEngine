
const float unit_scale = 0.01905f;

class BSPMap : PhysicsComponent
{
    Vertex[][] vertices;
	string[] textures;

	BSPMap(string filename)
	{
		ConfigFile cfg;
        if (cfg.loadFile(CFileMatcher(filename).getFirst()))
        {
			Texture::createFromFile("none", "none.png");
			//string[] textures;
			int tris_size = 0;
            cfg.readIntoArray_string(textures, "textures");
			for(int t = 0; t < textures.size(); t++)
			{
				Vertex[] vertss;
				f32[] verts;
            	cfg.readIntoArray_f32(verts, textures[t]);
				Texture::createFromFile(textures[t], textures[t]+".png");
				ImageData@ tex_data = Texture::data(textures[t]);
				Vec2f wh = Vec2f(16,16);
				if(tex_data !is null)
					wh = Vec2f(tex_data.width(), tex_data.height());
				//else
					//textures[t] = "none";

				//TriangleBody[] tris;
				const int size = verts.size();
				//tris.resize(size/9); // 9 - 3 floats xyz for each vert in TRIANGLE (3*3 = 9)
				//int iterator = 0;
				tris_size += size/5/3;
				for(int i = 0; i < size; i += 5)
				{
					vertss.push_back(Vertex(verts[i]*unit_scale, verts[i+1]*unit_scale, verts[i+2]*unit_scale, verts[i+3]/wh.x, verts[i+4]/wh.y));
					//tris[iterator] = TriangleBody(Vec3f(0-verts[i], verts[i+1], verts[i+2]), Vec3f(0-verts[i+3], verts[i+4], verts[i+5]), Vec3f(0-verts[i+6], verts[i+7], verts[i+8]));
					//tris[iterator].bod_id = iterator;
					//iterator++;
				}
				vertices.push_back(vertss);
			}

			TriangleBody[] tris;
			tris.resize(tris_size);
			int iterator = 0;
			for(int i = 0; i < vertices.size(); i++)
			{
				for(int j = 0; j < vertices[i].size(); j += 3)
				{
					tris[iterator] = TriangleBody(Vec3f(vertices[i][j].x, vertices[i][j].y, vertices[i][j].z), Vec3f(vertices[i][j+1].x, vertices[i][j+1].y, vertices[i][j+1].z), Vec3f(vertices[i][j+2].x, vertices[i][j+2].y, vertices[i][j+2].z));
					tris[iterator].bod_id = iterator;
					iterator++;
				}
			}
			MeshBody _body = MeshBody(tris);

			super(PhysicsComponentType::STATIC, _body);
			hooks |= CompHooks::RENDER;
        	name = "BSPMap";
		}
		else
		{
			print("no "+filename+" file found.");
			super(PhysicsComponentType::STATIC, null);
			name = "BSPMap";
		}
	}

	void Render()
	{
		float[] model;
		Matrix::MakeIdentity(model);
        //Matrix::SetTranslation(model, interpolated_position.x, interpolated_position.y, interpolated_position.z);
        //Matrix::SetScale(model, entity.transform.scale.x, entity.transform.scale.y, entity.transform.scale.z);
        Render::SetModelTransform(model);

        //Render::RawTriangles("default.png", vertices);
		for(int i = 0; i < textures.size(); i++)
		{
			Render::RawTriangles(textures[i], vertices[i]);
		}
	}
}