/*
 * \brief  Terminal session interface
 * \author Norman Feske
 * \date   2018-02-06
 */

/*
 * Copyright (C) 2018 Genode Labs GmbH
 *
 * This file is part of the Genode OS framework, which is distributed
 * under the terms of the GNU Affero General Public License version 3.
 */

#ifndef _SESSION_H_
#define _SESSION_H_

/* Genode includes */
#include <root/component.h>
#include <terminal_session/terminal_session.h>

/* local includes */
#include "types.h"

namespace Terminal {
	class Session_component;
	class Root_component;
}


class Terminal::Session_component : public Rpc_object<Session, Session_component>
{
	private:

		Read_buffer            &_read_buffer;
		Character_consumer     &_character_consumer;
		Size             const &_terminal_size;
		Attached_ram_dataspace  _io_buffer;

		Terminal::Position _last_cursor_pos { };

	public:

		/**
		 * Constructor
		 */
		Session_component(Env                &env,
		                  Read_buffer        &read_buffer,
		                  Character_consumer &character_consumer,
		                  Size         const &terminal_size,
		                  size_t              io_buffer_size)
		:
			_read_buffer(read_buffer),
			_character_consumer(character_consumer),
			_terminal_size(terminal_size),
			_io_buffer(env.ram(), env.rm(), io_buffer_size)
		{ }


		/********************************
		 ** Terminal session interface **
		 ********************************/

		Size size() override { return _terminal_size; }

		bool avail() override { return !_read_buffer.empty(); }

		size_t _read(size_t dst_len)
		{
			/* read data, block on first byte if needed */
			unsigned       num_bytes = 0;
			unsigned char *dst       = _io_buffer.local_addr<unsigned char>();
			size_t dst_size          = min(_io_buffer.size(), dst_len);

			while (!_read_buffer.empty() && num_bytes < dst_size)
				dst[num_bytes++] = _read_buffer.get();

			return num_bytes;
		}

		size_t _write(size_t num_bytes)
		{
			unsigned char *src = _io_buffer.local_addr<unsigned char>();

			for (unsigned i = 0; i < num_bytes; i++)
				_character_consumer.consume_character(src[i]);

			return num_bytes;
		}

		Dataspace_capability _dataspace() { return _io_buffer.cap(); }

		void connected_sigh(Signal_context_capability sigh) override
		{
			/*
			 * Immediately reflect connection-established signal to the
			 * client because the session is ready to use immediately after
			 * creation.
			 */
			Signal_transmitter(sigh).submit();
		}

		void read_avail_sigh(Signal_context_capability cap) override
		{
			_read_buffer.sigh(cap);
		}

		size_t read(void *, size_t) override { return 0; }
		size_t write(void const *, size_t) override { return 0; }
};


class Terminal::Root_component : public Genode::Root_component<Session_component>
{
	private:

		Env                &_env;
		Read_buffer        &_read_buffer;
		Character_consumer &_character_consumer;
		Session::Size      &_terminal_size;

	protected:

		Session_component *_create_session(const char *)
		{
			/*
			 * XXX read I/O buffer size from args
			 */
			size_t io_buffer_size = 4096;

			return new (md_alloc())
				Session_component(_env,
				                  _read_buffer,
				                  _character_consumer,
				                  _terminal_size,
				                  io_buffer_size);
		}

	public:

		/**
		 * Constructor
		 */
		Root_component(Env                &env,
		               Allocator          &md_alloc,
		               Read_buffer        &read_buffer,
		               Character_consumer &character_consumer,
		               Session::Size      &terminal_size)
		:
			Genode::Root_component<Session_component>(env.ep(), md_alloc),
			_env(env),
			_read_buffer(read_buffer),
			_character_consumer(character_consumer),
			_terminal_size(terminal_size)
		{ }
};

#endif /* _SESSION_H_ */
