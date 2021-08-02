/*
 * Copyright (c) 2017-2021 Teradata
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.teradata.jaqy.typehandler;

import java.sql.SQLException;

import com.teradata.jaqy.JaqyInterpreter;
import com.teradata.jaqy.interfaces.JaqyResultSet;
import com.teradata.jaqy.utils.StringUtils;

/**
 * @author  Heng Yuan
 */
class ObjectTypeHandler implements TypeHandler
{
    private final static TypeHandler s_instance = new ObjectTypeHandler ();

    public static TypeHandler getInstance ()
    {
        return s_instance;
    }

    private ObjectTypeHandler ()
    {
    }

    @Override
    public String getString (JaqyResultSet rs, int columnIndex, JaqyInterpreter interpreter) throws SQLException
    {
        Object o = rs.getObject (columnIndex);
        return StringUtils.getDbObjectString (o);
    }

    @Override
    public int getLength (JaqyResultSet rs, int column, JaqyInterpreter interpreter) throws SQLException
    {
        Object o = rs.getObject (column);
        return (int)StringUtils.getDbObjectStringLength (o);
    }
}
