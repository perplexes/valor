int doortimer;
short cfg_doordelay;
short cfg_doormode;
int doorseed;

int ssprng(int seed)
{
	int newseed, work;
	long long edxeax;

	newseed = (seed % 127773) * 16807;
	edxeax = 0x834E0B5F * (long long)seed;
	work = edxeax >> 32;
	work += seed;
	work = (work >> 16) + ((unsigned int)work >> 31);
	newseed -= work * 2836;
	newseed += 123;

	if (newseed <= 0)
	    newseed = newseed + 0x7fffffff;

	return newseed;
}

void doorsync(int updatedoors, int somecounter)
{
	int newmode;

	doortimer++;

	if (doortimer >= cfg_doordelay)
	{
		doortimer = 0;
		updatedoors = 1;

		if (cfg_doormode == -2)
		{
			doorseed = ssprng(doorseed);
			newmode = doorseed & 0xff;
		}
		else if (cfg_doormode == -1)
		{
			newmode = 0;

			doorseed = ssprng(doorseed);
			if (doorseed & 1)
			    newmode = 0x00000011;

			doorseed = ssprng(doorseed);
			if (doorseed & 3)
				newmode |= 0x00000002;

			doorseed = ssprng(doorseed);
			if (doorseed & 7)
				newmode |= 0x00000004;

			doorseed = ssprng(doorseed);
			if (doorseed & 0xf)
				newmode |= 0x00000008;

			doorseed = ssprng(doorseed);
			if (doorseed & 3)
				newmode |= 0x00000020;

			doorseed = ssprng(doorseed);
			if (doorseed & 7)
				newmode |= 0x00000040;

			doorseed = ssprng(doorseed);
			if (doorseed & 0xf)
				newmode |= 0x00000080;
		}
		else
		{
			newmode = cfg_doormode;
		}
	}
	else
	{
		ebp = 0;
	}

	/* final (0041C284) */
}

